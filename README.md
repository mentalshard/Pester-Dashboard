# Pester-Dashboard

## Description
The goal of this project is the effortless display of Pester test results in a webapp by simply pointing to a directory containing the .xml files. This will be accomplished using the power of PowerShell Universal Dashboard which allows a fully functioning webapp to be run from PowerShell.

My implementation of this vision uses extensive use of the Cache Provider built into PowerShell Universal Dashboard to read and retrieve objects *almost* ready to display. I am using dynamic pages and the relative paths in the directory structure as urls. 

## Roadmap

1. Complete building the pester test page (currently only roughed in)
2. Breadcrumbs for directory and test pages
3. Ability to refresh individual page cache
4. Allow multiple starting directories
5. Take input from pester tests directly (without requiring a .xml file)