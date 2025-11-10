INTEGRATION_TEST_DIR=uploads/certain_test/converted
PROCESSOR_ROOT_DIR=processor

test:
	cd $(PROCESSOR_ROOT_DIR) && go test -v -cover -short ./tests/...

clean:
	rm -rf $(INTEGRATION_TEST_DIR)

