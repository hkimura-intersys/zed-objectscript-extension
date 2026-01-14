use std::fs;

use zed_extension_api::{
    self as zed,
    settings::LspSettings,
    LanguageServerId,
    Result,
};

struct ObjectScriptBinary {
    path: String,
    args: Vec<String>,
}

struct ObjectScriptExtension {
    cached_binary_path: Option<String>,
}

impl ObjectScriptExtension {
    fn language_server_binary(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<ObjectScriptBinary> {
        // Read user/worktree LSP settings for this language server id ("objectscript-lsp")
        let settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree).ok();

        // Optional user override: explicit binary path + args from settings
        let binary = settings.as_ref().and_then(|s| s.binary.clone());
        let args = binary
            .as_ref()
            .and_then(|b| b.arguments.clone())
            .unwrap_or_default();

        // Binary resolution order:
        // 1) settings.binary.path
        // 2) PATH lookup in the worktree environment
        // 3) Zed-managed download from GitHub releases
        let path = binary
            .and_then(|b| b.path)
            .or_else(|| worktree.which("objectscript-lsp"))
            .unwrap_or(self.zed_managed_binary_path(language_server_id)?);

        Ok(ObjectScriptBinary { path, args })
    }

    fn zed_managed_binary_path(&mut self, language_server_id: &LanguageServerId) -> Result<String> {
        // If we've already downloaded it, reuse it if it still exists
        if let Some(path) = &self.cached_binary_path {
            if fs::metadata(path).is_ok_and(|m| m.is_file()) {
                return Ok(path.clone());
            }
        }

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::CheckingForUpdate,
        );

        //  objectscript-lsp repo
        let release = zed::latest_github_release(
            "hkimura-intersys/objectscript-lsp",
            zed::GithubReleaseOptions {
                require_assets: true,
                pre_release: false,
            },
        )?;

        let (os, arch) = zed::current_platform();

        //  release workflow uses these platform labels
        // (IMPORTANT: Zed can't detect alpine vs glibc; choose one default for Linux.)
        let platform_label = match (os, arch) {
            (zed::Os::Mac, zed::Architecture::X8664) => "darwin-x64",
            (zed::Os::Mac, zed::Architecture::Aarch64) => "darwin-arm64",

            (zed::Os::Windows, zed::Architecture::X8664) => "win32-x64",
            (zed::Os::Windows, zed::Architecture::Aarch64) => "win32-arm64",

            // Default to glibc assets on Linux:
            // TODO: if prefer musl by default, change these to "alpine-x64"/"alpine-arm64".. still deciding
            (zed::Os::Linux, zed::Architecture::X8664) => "linux-x64",
            (zed::Os::Linux, zed::Architecture::Aarch64) => "linux-arm64",

            (_, zed::Architecture::X86) => return Err("unsupported platform x86".into()),
        };

        let ext = match os {
            zed::Os::Windows => "zip",
            zed::Os::Mac | zed::Os::Linux => "tar.gz",
        };

        // Matches assets produced by workflow in objectscript-lsp repo:
        // objectscript-lsp-v0.1.0-linux-x64.tar.gz
        let asset_name = format!(
            "objectscript-lsp-{version}-{platform}.{ext}",
            version = release.version,
            platform = platform_label,
            ext = ext
        );

        let asset = release
            .assets
            .iter()
            .find(|a| a.name == asset_name)
            .ok_or_else(|| format!("no asset found matching {asset_name:?}"))?;

        // Matches packaging directory name:
        // objectscript-lsp-v0.1.0-linux-x64/bin/objectscript-lsp(.exe)
        let version_dir = format!("objectscript-lsp-{}-{}", release.version, platform_label);

        let binary_path = format!(
            "{dir}/bin/objectscript-lsp{exe}",
            dir = version_dir,
            exe = match os {
                zed::Os::Windows => ".exe",
                _ => "",
            }
        );

        // Download/extract if not already present
        if !fs::metadata(&binary_path).is_ok_and(|m| m.is_file()) {
            zed::set_language_server_installation_status(
                language_server_id,
                &zed::LanguageServerInstallationStatus::Downloading,
            );

            zed::download_file(
                &asset.download_url,
                &version_dir,
                match os {
                    zed::Os::Windows => zed::DownloadedFileType::Zip,
                    zed::Os::Mac | zed::Os::Linux => zed::DownloadedFileType::GzipTar,
                },
            )
                .map_err(|e| format!("failed to download file: {e}"))?;

            // Optional cleanup: keep only the current version_dir in this working directory
            if let Ok(entries) = fs::read_dir(".") {
                for entry in entries.flatten() {
                    if entry.file_name().to_str() != Some(&version_dir) {
                        let _ = fs::remove_dir_all(entry.path());
                    }
                }
            }
        }

        self.cached_binary_path = Some(binary_path.clone());
        Ok(binary_path)
    }
}

impl zed::Extension for ObjectScriptExtension {
    fn new() -> Self {
        Self {
            cached_binary_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let bin = self.language_server_binary(language_server_id, worktree)?;
        Ok(zed::Command {
            command: bin.path,
            args: bin.args,
            env: vec![],
        })
    }

    //  This forwards Config (enable_snippets / enable_formatting / enable_lint / enable_strict_mode)
    // from Zed settings into the LSP initialize request as `initializationOptions`.
    fn language_server_initialization_options(
        &mut self,
        server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        LspSettings::for_worktree(server_id.as_ref(), worktree)
            .map(|s| s.initialization_options.clone())
    }

    // a separate channel of configuration that is NOT initializationOptions.
    // Many servers use this for workspace/didChangeConfiguration.
    fn language_server_workspace_configuration(
        &mut self,
        server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        LspSettings::for_worktree(server_id.as_ref(), worktree)
            .map(|s| s.settings.clone())
    }
}

zed::register_extension!(ObjectScriptExtension);

// TODO : I might want to set label_for_completion and label_for_symbol
