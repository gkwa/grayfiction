```bash
packer --help
packer fmt .
packer init .

# this works
time packer build -var-file=variables.json aws-ubuntu.pkr.hcl -force

# add timestamps to logs
time packer build -force -timestamp-ui -var-file=variables.json aws-ubuntu.pkr.hcl -force

# while iterating -force helps
time packer build -var-file=variables.json aws-ubuntu.pkr.hcl -force
```
