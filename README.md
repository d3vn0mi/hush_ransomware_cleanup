# Hush Files Collector

A PowerShell script that recursively searches for `.hush` files across your system, collects them into a single location, and creates a compressed archive for easy backup or transfer.

## 🚀 Features

- **Recursive Search**: Scans directories and subdirectories to find all `.hush` files
- **Smart Collection**: Moves files to a temporary collection folder with duplicate name handling
- **Automatic Compression**: Creates a timestamped ZIP archive of all collected files
- **Comprehensive Logging**: Detailed operation log with error tracking
- **Error Resilience**: Continues processing even if individual files fail
- **Automatic Cleanup**: Removes temporary files after successful archiving

## 📋 Prerequisites

- Windows PowerShell 5.1 or PowerShell Core 6.0+
- Appropriate file system permissions for the search path and output location
- .NET Framework (for ZIP compression functionality)

## 🔧 Installation

1. Download the script file `collect_hush_files.ps1`
2. Place it in your desired location
3. Ensure PowerShell execution policy allows script execution:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## 📖 Usage

### Basic Usage

```powershell
# Search current directory and subdirectories
.\collect_hush_files.ps1
```

### Advanced Usage

```powershell
# Search specific path
.\collect_hush_files.ps1 -SearchPath "C:\MyDocuments"

# Custom output filename
.\collect_hush_files.ps1 -ZipFileName "my_hush_backup.zip"

# Full customization
.\collect_hush_files.ps1 -SearchPath "D:\Projects" -CollectionFolder "temp_collection" -ZipFileName "hush_archive_2024.zip" -LogFile "collection_log.txt"
```

## ⚙️ Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `SearchPath` | String | `"."` | Starting directory for recursive search |
| `CollectionFolder` | String | `"hush_files_collection"` | Temporary folder for collecting files |
| `ZipFileName` | String | `"hush_files_YYYYMMDD_HHMMSS.zip"` | Output ZIP file name |
| `LogFile` | String | `"hush_collection_log.txt"` | Log file name |

## 📁 Output Files

The script generates the following files:

1. **ZIP Archive**: Contains all collected `.hush` files
   - Default name: `hush_files_YYYYMMDD_HHMMSS.zip`
   - Location: Current directory

2. **Log File**: Detailed operation log
   - Default name: `hush_collection_log.txt`
   - Contains: Search results, file movements, errors, and summary

## 🔍 Example Output

```
Hush Files Collection Log - 12/07/2024 14:30:15
============================================================
Search Path: C:\Users\Username\Documents
Collection Folder: C:\PowerShell\hush_files_collection
Zip File: C:\PowerShell\hush_files_20241207_143015.zip
============================================================
Found Files: 15

Moving Files:
MOVED: C:\Users\Username\Documents\project1\config.hush -> config.hush
MOVED: C:\Users\Username\Documents\project2\settings.hush -> settings.hush
MOVED: C:\Users\Username\Documents\backup\config.hush -> config(1).hush
...

============================================================
SUMMARY:
Files found: 15
Files moved: 15
Errors: 0
Zip created: C:\PowerShell\hush_files_20241207_143015.zip
Completed: 12/07/2024 14:30:45
```

## 🛡️ Error Handling

The script includes robust error handling:

- **File Access Errors**: Continues processing other files if some are inaccessible
- **Duplicate Names**: Automatically renames files with numeric suffixes
- **Permission Issues**: Logs errors and continues with accessible files
- **Disk Space**: Validates operations and provides clear error messages

## ⚠️ Important Notes

- **File Movement**: The script **moves** (not copies) files to the collection folder
- **Original Locations**: File original paths are logged for reference
- **Permissions**: Ensure you have read/write permissions for the search path
- **Backup**: Consider backing up important files before running the script

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Troubleshooting

### Common Issues

**"Execution Policy" Error**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**"Access Denied" Errors**
- Run PowerShell as Administrator
- Check file/folder permissions
- Ensure antivirus isn't blocking the script

**"No Files Found"**
- Verify the search path exists
- Check if `.hush` files actually exist in the specified location
- Ensure proper file extensions (case-sensitive on some systems)

**ZIP Creation Fails**
- Check available disk space
- Ensure .NET Framework is properly installed
- Verify write permissions in the output directory

## 📊 Version History

- **v1.0.0** - Initial release
  - Recursive file search
  - File collection and ZIP creation
  - Comprehensive logging
  - Error handling

## 🙋‍♂️ Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Review the log file for detailed error information
3. Open an issue on GitHub with:
   - Your PowerShell version (`$PSVersionTable`)
   - Operating system details
   - Complete error messages
   - Steps to reproduce the issue

---
