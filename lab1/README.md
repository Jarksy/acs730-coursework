# Lab 1

create-security-group.sh: Creates a security group (acs730-week1-sg) that restricts SSH access to only your current IP address.    

⁠create-instance.sh: Launches a t3.micro EC2 instance and attaches the LabInstanceProfile for AWS permissions.    

⁠delete-instance.sh: Finds any instances tagged as acs730-week1 and terminates them.    

⁠delete-security-group.sh: Deletes the acs730-week1-sg security group.  

create-security-group.sh: Creates a security group (acs730-week1-sg) that restricts SSH access to only your current IP address. 

## Experiments

Experiment 3: Idempotent-ish deletes  

Predict: Running the delete script twice will do nothing instead of throwing an AWS error.  
Explanation: The first run terminated successfully, on second run, the terminal simply printed “Nothing to delete” and exited cleanly with no errors. 

Experiment 5: The safety net, tested safely

Predict: Git will ignore the fake.pem file first, but it will immediately pop up as untracked once the .gitignore rule is commented out.  
Explanation: At first, git status ignored the file completely. The moment I commented out the *.pem line, fake.pem immediately popped up in red as an untracked file. 
