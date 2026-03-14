# 📁 File Explorer

> **A modern, secure web-based file manager built with Ruby on Rails 7.2**

<div align="center">

[![Ruby Version](https://img.shields.io/badge/Ruby-4.0+-ruby.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/Rails-7.2+-ruby.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

![Screenshot](/images/screenshot.png?raw=true)

*A clean, intuitive interface for managing your files*

</div>

---

## ✨ Features

- 👀 **Browse** directory contents with file size and modification date
- 📄 **Preview** file contents inline (up to 1MB) or download directly
- ⬆️ **Upload** files to any directory
- ✏️ **Rename** files and directories
- 🗑️ **Delete** unwanted files and folders
- 🧭 **Breadcrumb** navigation for easy path tracking
- 🌙 **Dark mode** support
- 🔒 **Security-first** design with path validation and size limits
- 💎 **Ruby 4** ready

---

## 🏗️ Architecture

This refactored codebase follows modern software design patterns:

### Service Objects ⚙️

| Service | Description |
|---------|-------------|
| `PathSecurityValidator` | Validates paths to prevent directory traversal |
| `DirectoryBrowser` | Lists directory entries safely with metadata |
| `FileSystemOperations` | Handles file operations with validation & limits |
| `FileUploadService` | Manages secure file uploads |
| `FileDeletionService` | Handles safe file deletion |
| `FileOperationService` | Manages file rename/move operations |

### Value Objects 📦

- `DirectoryInfo` - Encapsulates directory view state
- `DirectoryEntry` - Represents a file/directory entry
- `Breadcrumb` - Navigation breadcrumb items

### Security 🔐

- ✅ Path traversal prevention
- ✅ File size limits (100MB by default)
- ✅ MIME type validation
- ✅ Request size limits
- ✅ Security headers (CSP, XSS protection, SRI)

---

## 🚀 Getting Started

### Requirements

- **Ruby** 4.0 or higher
- **Rails** 7.2 or higher
- **Node.js** (for asset compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/adrientoub/file-explorer.git
   cd file-explorer
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Run the server**
   ```bash
   bundle exec rails s -b 0.0.0.0
   ```

Visit `http://localhost:3000` to start exploring!

---

## ⚙️ Configuration

Set environment variables to customize behavior:

| Variable | Description | Default |
|----------|-------------|---------|
| `BASE_DIRECTORY` | Directory to explore | `.` (current directory) |
| `BASE_URL` | Display URL for breadcrumbs | `root` |
| `FORCE_SSL` | Force HTTPS in production | `true` |

```bash
BASE_DIRECTORY=/path/to/directory BASE_URL=myfiles bundle exec rails s -b 0.0.0.0
```

### Environment Files

Create `.env.{environment}` files for configuration:

```bash
# .env.production
BASE_DIRECTORY=/var/www/files
BASE_URL=https://files.example.com
FORCE_SSL=true
```

---

## 🐳 Docker

### Build the Image

```bash
docker build -t fileexplorer .
```

### Run Container

```bash
docker run -p 127.0.0.1:8689:3000 \
  -e SECRET_KEY_BASE=YOUR_SECRET \
  -e BASE_DIRECTORY=/ \
  -v /your/directory:/mounted \
  fileexplorer
```

### Use Pre-built Image

```bash
docker run -p 127.0.0.1:8689:3000 \
  -e SECRET_KEY_BASE=YOUR_SECRET \
  -e BASE_DIRECTORY=/ \
  -v /your/directory:/mounted \
  adrientoub/file-explorer:latest
```

---

## 🛡️ Security

> ⚠️ **IMPORTANT:** You MUST protect access at the web server level. The application has no built-in authentication.

### Recommended Protections

#### Apache Basic Auth
```apache
<Directory "/var/www/file-explorer">
    AuthType Basic
    AuthName "Restricted Access"
    AuthUserFile /path/to/.htpasswd
    Require valid-user
</Directory>
```

#### Nginx Basic Auth
```nginx
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /path/to/.htpasswd;
    try_files $uri $uri/ @rails;
}
```

### Security Headers
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`
- `Content-Security-Policy` (production)
- `Strict-Transport-Security` (production)

---

## 🎨 Project Structure

```
app/
├── controllers/
│   ├── concerns/
│   │   └── file_system_security.rb    # Security concerns
│   └── index_controller.rb             # Main controller
├── models/
│   ├── breadcrumb.rb                   # Navigation items
│   ├── directory_entry.rb              # File/directory entries
│   └── directory_info.rb               # Directory state
├── services/                           # Business logic
│   ├── file_deletion_service.rb
│   ├── file_operation_service.rb
│   ├── file_system_operations.rb
│   └── path_security_validator.rb
├── views/
│   ├── index/
│   │   ├── index.html.erb              # Directory listing
│   │   ├── file.html.erb               # File preview
│   │   └── _directory_entry.html.erb   # Entry partial
│   ├── shared/
│   │   └── _breadcrumbs.html.erb       # Navigation
│   └── layouts/
│       └── application.html.erb        # Main layout
└── assets/
    └── javascripts/
        └── rename.js                   # Modern rename handler
```

---

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
bundle exec rake test

# Run specific test file
bundle exec rake test TEST=test/services/file_system_operations_test.rb

# Run with verbose output
bundle exec rake test TESTOPTS="--verbose"
```

### Code Quality

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

---

## 🔄 Latest Changes

### v2.0 - Major Refactoring (2026-03-14)

This major update modernizes the entire codebase with:

#### 🎯 Architecture Improvements
- **Service Objects Pattern** - Extracted business logic from controllers
- **Value Objects** - Created DirectoryInfo, DirectoryEntry, Breadcrumb
- **Security Concerns** - Centralized security logic
- **Policies** - Authorization framework

#### 🔒 Security Enhancements
- Path traversal prevention
- File size limits (100MB max)
- MIME type validation
- Security headers and CSP
- Request size limits

#### 💎 Modernization
- Ruby 4 compatibility (`File.exists?` → `File.exist?`)
- Rails 7.2 upgrade
- Pathname usage throughout
- Async/await JavaScript
- Modern Ruby syntax

#### 📁 Added Files
```
app/services/          # 6 service objects
app/models/            # 3 value objects
app/policies/          # 1 policy object
app/controllers/concerns/  # 1 concern
app/views/shared/      # 1 partial
test/services/         # 2 test suites
test/models/           # 2 test suites
config/initializers/security.rb
```

#### 🎨 UI Updates
- Cleaner breadcrumb navigation
- Improved directory_entry partial
- Modern rename.js with namespace
- Better CSS styling

#### 📖 Documentation
- Complete README rewrite
- Architecture documentation
- Security guide
- Docker instructions

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`bundle exec rake test`)
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

---

## 📝 License

This project is maintained as-is for server file management needs.

---

<div align="center">

Made with ❤️ by the Rails community

[⭐ Star](https://github.com/adrientoub/file-explorer) · [🐛 Report Bug](https://github.com/adrientoub/file-explorer/issues) · [💡 Feature Request](https://github.com/adrientoub/file-explorer/issues)

</div>
