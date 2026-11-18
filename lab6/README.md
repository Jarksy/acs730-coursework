# Lab 6

## Overview
This repository contains the infrastructure code, configuration playbooks, and evidence for Lab 6. The project automates provisioning EC2 instances using Terraform, configuring them with Ansible through AWS Systems Manager Session Manager, and building golden machine images using Packer.

## Architecture and Mechanisms
The pipeline uses AWS Systems Manager Session Manager to connect the runner to the target instances securely. This mechanism completely avoids opening port 22 to the world and eliminates the need to store long-lived private keys in repository secrets. 

Running the Ansible playbook a second time results in zero changes across all tasks. This outcome proves that every task checks the actual state of the host and confirms it already matches the expected configuration. It ensures the playbook is safe to run repeatedly, both on new instances and inside an automated CI/CD pipeline on every merge.

## Golden AMI versus Boot Convergence
Deregistering an Amazon Machine Image is not enough because the image serves only as a pointer to the underlying EBS snapshot. The snapshot stores the actual data and incurs ongoing storage costs, and once the image is deregistered, you can no longer trace which snapshot belonged to it. 

### Comparison Table
The table below compares the two deployment paths based on measured boot and readiness times.

| Metric | Slow Path (Boot Convergence) | Fast Path (Golden AMI) |
| :--- | :--- | :--- |
| **Instance Launch Time** | 40 seconds | 25 seconds |
| **Configuration and Readiness** | 110 seconds | 5 seconds |
| **Total Time to HTTP 200** | 150 seconds | 30 seconds[cite: 1] |

The slow path spends most of its time waiting for the SSM agent to register and for package managers to download dependencies over the network on every single launch. The golden AMI path moves this work to the build phase, allowing instances to boot and serve traffic almost immediately[cite: 1].

## Recommendation
Golden AMI is the recommended approach because it eliminates runtime network dependencies and significantly reduces startup times when launching instances at scale. This choice would only change if application updates happen so frequently that the overhead of rebuilding images outweighs the benefit of fast boots.

## Experiments

### Experiment 2: state:latest Versus state:present
- **Prediction:** I think if I change the dnf task to latest and run it again, it won't show any changes unless a package happened to update overnight, but it probably depends on the day because packages get patched randomly.
- **Explanation:** When I ran it, the second run didn't show changes on a normal day, but using latest in a pipeline is risky because it can unexpectedly pull newer package versions on a merge and break things without warning.

### Experiment 4: Make the Inventory Shrink
- **Prediction:** I figured that if I stopped one instance and checked the inventory graph, it would either disappear entirely or show up as stopped, and running the playbook would probably fail or hang when it hits a dead host.
- **Explanation:** The inventory graph still showed the instances, but once I removed the state filter, the playbook skipped the stopped instance gracefully instead of crashing, which shows how Ansible handles inactive targets.
