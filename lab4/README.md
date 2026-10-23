# Lab 4

## Image Size Comparison

| Image | Base Image | Size | Rebuild Time (One-Line Code Change) |
| :--- | :--- | :--- | :--- |
| **Naive** (`acs730-lab4:naive`) | `python:latest` | 1.15 GB | 25.655s |
| **Slim** (`acs730-lab4:slim`) | `python:3.12-slim-bookworm` | 130 MB | 0.631s |

* Almost all of the size difference comes from the base image because the naive version starts with a huge full Linux system containing extra tools and compilers.
* The dependency layer stays cached on a code-only rebuild in the slim image because the requirements file is copied before the code.
* The `.dockerignore` file keeps junk like git history, local cache folders, and screenshots out of the build so it stays small.

## CI Performance & Caching Analysis

### CI Timings Table

| Measurement / Step | Baseline | Cache Miss | Cache Hit | Worth-It? |
| :--- | :---: | :---: | :---: | :--- |
| **Pip Install Step** | 8s | 11s | 10s | Yes – saves time by not downloading python packages again. |
| **Docker Build Step** | 24s | 34s | 22s | Yes – builds faster by reusing saved parts. |
| **Whole Workflow (Wall Clock)** | 66s | 72s | 74s | Yes – keeps total run times steady and reliable. |

## Pipeline Design Choices

- The dependency setup is an action because its steps must run on the same runner as the tests.
- The image build is a workflow because it is a whole job needing `packages: write` permissions that the test job must not have.
