PKR_FILE := aws-ubuntu.pkr.hcl
VAR_FILE := variables.json
LOG_FILE := packer.log

.PHONY: all
all: run

$(VAR_FILE): $(VAR_FILE).sample
	cp $< $@

.PHONY: run
run: $(VAR_FILE)
	time packer build -force -timestamp-ui -var-file=$< $(PKR_FILE) | tee -a $(LOG_FILE)

pretty: check

check:
	packer fmt -recursive .
	packer validate -syntax-only .

clean:
	rm -f $(LOG_FILE)
