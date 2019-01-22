# Pester-Dashboard

## Description
The goal of this project is the effortless display of Pester test results in a webapp by simply pointing to a directory containing the .xml files. This will be accomplished using the power of PowerShell Universal Dashboard which allows a fully functioning webapp to be run from PowerShell.

My implementation of this vision uses the Cache Provider built into PowerShell Universal Dashboard extensively to read and retrieve objects *almost* ready to display. I am using dynamic pages and the relative paths in the directory structure as urls. 

## Screenshots
### Home Page
The 'home' or root directory that holds the file structure with the .xml files.
![Home Page](https://github.com/Richard-B12/ImageSrc/blob/master/PD_Home_Screenshot.PNG)

### Directory Page
Displays the contents of a directory, both child directories and any test .xml files that reside in it.
![Directory Page](https://github.com/Richard-B12/ImageSrc/blob/master/DirectoryPage_Screenshot.PNG)

### Test Page
Displays the results of the tests. A summary of the results is provided in the graphs at the top and individual pester describe blocks contain the results their tests as a collapsable element. After expanding the element,  you can then use a filter to search within each.
![Test Page](https://github.com/Richard-B12/ImageSrc/blob/master/TestPage_Screenshot.PNG)



## Original Requirements

- [x] Automatically update content when new tests are added to the directory
- [x] Each test and directory needs to have a direct url
- [x] Page content should be stored already put into UD objects for performance
- [x] Initial configuration should be as simple as setting a single directory

## Roadmap
### Minor Features
- [ ] Complete building the pester test page (currently only roughed in)
- [x] Breadcrumbs for directory and test pages
- [ ] Update grid content with graphical status elements

### Major Features
- [ ] Allow multiple starting directories
- [ ] Take input from pester tests directly (without requiring a .xml file)
- [ ] Ability to refresh individual page cache
