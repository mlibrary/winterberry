# winterberry

## Table of Contents
* Introduction
* Prerequisites
* Setup
* Usage

## Introduction
This repository manages the implementation for processing Fulcrum monographs. See the following Jira tickets:
1. HELIO-2455
2. HELIO-2545.

## Prerequisites
* Ruby 2.5.5.
* bundler 2.0 or greater.

## Setup
1. Clone the repository.
2. Invoke "bundle package".
3. The environment variable **WINTERBERRY_FULCRUM_UMP_DIR** can be used to specify the root directory for 
locating monograph EPUB files. Otherwise, this directory can be specified as a command line option. By default,
the current working directory is used.
4. The environment variable **WINTERBERRY_PRODUCTION_DIR** can be used to specify the root directory fo
creating the project directories. Otherwise, this directory can be specified as a command line option. By default,
the current working directory is used.

## Usage
Steps:

1. **Create a resource project.** Invoke _script/create_resource_project_. This script creates 
one or more project directories, storing the monograph EPUB file and manifest. 
Below is is the command syntax:
    ```
    create_resource_project [-p <project_root_dir>] [-s <source_root_dir>] <monograph_noid> [<monograph_noid>..]`
     
    source_root_dir      Root directory for locating monograph EPUB files.
    project_root_dir     Root directory for creating project directories.
    monograph_noid       Monograph NOID
    ```
 2. **Process a resource project.** Invoke _script/process_resource_project_. This script processes
 one or more project directories, either embedding Fulcrum resources or linking to Fulcrum resource pages.
 Below is the command syntax:
    ```
    process_resource_project [-e] [-d embed|link] <project_dir> [<project_dir>..]
     
    -e                  Execute processing.
    -d                  Default action, either embed or link.
    project_dir         Path to a project directory.
    ```
 3. **Collect resource project metadata.** Invoke _script/collect_resource_project_metadata_. This
 script, for each project specified, scans an EPUB found within and generates a CSV file that contains
 a row for each resource found, providing the NOID, caption text, alternative text.
 Below is the command syntax:
    ```
    collect_resource_project_metadata  <project_dir> [<project_dir>..]
     
    project_dir         Path to a project directory. 
    ``` 
