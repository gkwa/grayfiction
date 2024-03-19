```bash
packer --help
packer fmt .
packer init .

# this works
packer build -var-file=variables.json aws-ubuntu.pkr.hcl

# while iterating -force helps
packer build -var-file=variables.json aws-ubuntu.pkr.hcl -force
```
