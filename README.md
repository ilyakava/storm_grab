To run the Arch Daily scraper, type `ruby "run.rb"` in the terminal.

To search many queries on the Architizer website and make a table of results:
1. `irb`
2. make an array of queries (each item is a string, and is separated by commas, and surrounded by brackets: `[`) and save it to a variable, ex: `quereies = ["Populous"]`
3. Instantiate the `SearchArchitizer` class with the queries as its argument: `SearchArchitizer.new(queries)`
4. double click on the `table.html` output