COVERAGE_HTML = coverage/html

.PHONY: test test-coverage coverage-report clean

test:
	flutter test

test-coverage:
	flutter test --coverage

coverage-report: test-coverage
	genhtml coverage/lcov.info -o $(COVERAGE_HTML)
	@echo "Reporte de cobertura generado en $(COVERAGE_HTML)/index.html"

clean:
	rm -rf coverage/
