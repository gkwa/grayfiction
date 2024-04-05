run:
	time packer build -force -timestamp-ui -var-file=variables.json aws-ubuntu.pkr.hcl
