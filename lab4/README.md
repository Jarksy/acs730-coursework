# Lab 4

## Image Size Comparison

| Image | Base Image | Size | Rebuild Time (One-Line Code Change) |
| :--- | :--- | :--- | :--- |
| **Naive** (`acs730-lab4:naive`) | `python:latest` | 1.15 GB | 25.655s |
| **Slim** (`acs730-lab4:slim`) | `python:3.12-slim-bookworm` | 130 MB | 0.631s |

* Almost all of the size difference comes from the base image because the naive version starts with a huge full Linux system containing extra tools and compilers.
* The dependency layer stays cached on a code-only rebuild in the slim image because the requirements file is copied before the code.
* The `.dockerignore` file keeps junk like git history, local cache folders, and screenshots out of the build so it stays small.

