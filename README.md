# Pester-Dashboard

## Description
The goal of this project is the effortless display of Pester test results in a webapp by simply pointing to a directory containing the .xml files. This will be accomplished using the power of PowerShell Universal Dashboard which allows a fully functioning webapp to be run from PowerShell.

My implementation of this vision uses extensive use of the Cache Provider built into PowerShell Universal Dashboard to read and retrieve objects *almost* ready to display. I am using dynamic pages and the relative paths in the directory structure as urls. 

## Original Requirements

- [x] Automatically update content when new tests are added to the directory
- [x] Each test and directory needs to have a direct url
- [x] Page content should be stored already put into UD objects for performance
- [x] Initial configuration should be as simple as setting a single directory

## Roadmap
### Minor Features
- [] Complete building the pester test page (currently only roughed in)
- [] Breadcrumbs for directory and test pages
- [] Update grid content with graphical status elements

### Major Features
- [] Allow multiple starting directories
- [] Take input from pester tests directly (without requiring a .xml file)
- [] Ability to refresh individual page cache
