run:
	time packer build -force -timestamp-ui -var-file=variables.json aws-ubuntu.pkr.hcl

check:
	packer validate -syntax-only .
	packer fmt -recursive .
