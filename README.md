### About

Make the results rain down from the cloud.

![lightning pic](http://cl.ly/image/3G2Q2o3s3Z16/lightening_crack.png)
[image source](http://www.clipartpal.com/clipart_pd/weather/lightning_10217.html)

## Use Cases

1. Search the Architizer admin panel for matching firms
    * type `./bin/scrape_admin your_admin_username your_admin_password ` and then drag and drop a csv file containing firm names in each row into the terminal
    * NOTE: There **must*** exist a column **exactly** titled `Firm Name` (no extra spaces or typos) in the csv file that you provide. All other columns will be ignored.
    * the file that you provide will remain unmodified
    * the output is a `table.csv` file
        * there will be incremental backups every 100 firms when you run this script
            *  it is safe to ignore them if the process completes and a `table.csv` file is generated
            *  the backups are titled `table_backup_X.csv` where `X` is a number
                *  higher numbers mean the backup was created later, and has more recent data
            *  if your process keeps failing, gather what data you get from the latest backup file, and log an issue on this project
                -  i.e. find and click the "Issues" text on the right of this text, near the top of the web page
2. Search for a list of queries on the public facing Architizer.com
    * type `./bin/search ` and then drag and drop a csv file containing queries in each row into the terminal
    * every row in the csv becomes a single query
    * the output is a `table.csv` file
3. Scrape Architecture Blogs for new project (i.e. blog) entries
    * type `./bin/scrape` and scrape several architecture websites for entries
    * the output is a `table.html` file

### To do any of these actions:

* you must have `storm_grab` on your local computer, and you must **be in** the `storm_grab` directory in the Terminal
    * this means you must open the Terminal application
    * and type `cd `  (note the space) and then drag in the `storm_grab` folder that you have found in Finder, and hit enter
* always remember to update `storm_grab` (below) if you have not done so recently
* These should be givens:
    - You must have ruby installed
        + if on a mac, [follow this guide](http://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac)
        + else, google for it
    - You must have bundler installed
        + unless you know what you are doing: `sudo gem install bundler` and type in your password

### Updating Storm_grab

* assuming you are in the `storm_grab` directory (see above otherwise), and that **you have made no changes to storm_grab that you wish to preserve**
    * i.e. the following commands will discard any local changes you have made to `storm_grab`
* type `git fetch origin master` into Terminal
* then type `git reset FETCH_HEAD --hard`
* if you see error messages that you cannot resolve, skip to "Creating a Fresh storm_grab directory" below
* the final step is to type `bundle`

#### Creating a fresh storm_grab directory

* assuming that you are in a directory in Terminal that you wish to create a `storm_grab` directory in:
* type `git clone https://github.com/ilyakava/storm_grab.git`
* and then type `cd storm_grab` to have your working directory set to storm grab
* lastly type `bundle`
* now you are ready to run through any of the "Use Cases" of `storm_grab` above