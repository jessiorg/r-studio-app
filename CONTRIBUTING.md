# Contributing to RStudio Server Application

Thank you for considering contributing to this project! 🎉

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported
2. Create a new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (OS, Docker version, R version)
   - Logs if applicable

### Suggesting Enhancements

1. Check if the feature has been suggested
2. Create a new issue with:
   - Clear description of the feature
   - Use cases (especially trading/analysis scenarios)
   - Possible implementation approach
   - R packages that might be needed

### Pull Requests

1. **Fork the repository**

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Add tests if applicable
   - Update documentation
   - Test with RStudio Server

4. **Test your changes**
   ```bash
   # Build and test locally
   docker build -t rstudio-test .
   docker run -p 8787:8787 rstudio-test
   
   # Test deployment script
   sudo ./scripts/deploy.sh
   ```

5. **Commit your changes**
   ```bash
   git commit -m "Add feature: description"
   ```
   
   Commit format:
   - `Add feature: description` - New features
   - `Fix bug: description` - Bug fixes
   - `Update docs: description` - Documentation
   - `Add package: package-name` - New R packages

6. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

## Development Guidelines

### Adding R Packages

When adding new R packages to the Dockerfile:

```dockerfile
RUN install2.r --error --skipinstalled \
    new-package-name \
    another-package \
    && rm -rf /tmp/downloaded_packages/
```

- Group related packages together
- Add comments for package categories
- Test installation in container
- Update README with package description

### Example Scripts

When adding trading examples:

```r
# Include header comments
# Title: Brief description
# Author: Your name
# Date: 2026-03-04
# Purpose: What this script does

# Load required packages
library(quantmod)
library(TTR)

# Your code with comments
# ...
```

### Configuration Files

- Test all configuration changes
- Document new settings in README
- Provide sensible defaults
- Comment complex configurations

## Areas to Contribute

### High Priority

1. **Additional Trading Packages**
   - Crypto analysis tools
   - Machine learning for trading
   - Alternative data sources

2. **Example Scripts**
   - Trading strategies
   - Risk management examples
   - Portfolio optimization
   - Backtesting frameworks

3. **Documentation**
   - Video tutorials
   - Trading workflow guides
   - Package usage examples

4. **Performance Optimization**
   - Memory management
   - Parallel processing
   - Caching strategies

5. **Security**
   - Multi-user support
   - Authentication improvements
   - Data encryption

### Good First Issues

Look for issues labeled `good first issue` - perfect for newcomers!

## Testing

### Manual Testing

1. Build the Docker image
2. Run RStudio Server
3. Test all pre-installed packages
4. Run example scripts
5. Test resource limits
6. Verify persistence

### Package Testing

```r
# Test package installation
require(quantmod)
require(TTR)

# Test basic functionality
getSymbols("AAPL")
plot(AAPL)
```

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for users
- Show empathy

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal attacks
- Publishing others' private information
- Unprofessional conduct

## Questions?

- Open an issue for questions
- Join discussions
- Ask in pull requests

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be:
- Added to CONTRIBUTORS.md
- Mentioned in release notes
- Credited in documentation

Thank you for contributing! 🚀