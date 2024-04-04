run:
	time packer build -force -timestamp-ui -color=false -var-file=variables.json aws-ubuntu.pkr.hcl
