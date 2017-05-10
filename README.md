E2E Runners
===========

# Purpose

This repo is a simple testing framework that makes it easy to test scripts at a regular cadence and report the results via email. It is currently used for testing scripts focused on Azure VM Scale Set customer scenarios but could be used effectively for other scenarios as well.


# High Level Architecture And Behavior

The `runner.sh` file is responsible for running the scripts and reporting the result (it relies on the `run_script.sh` helper script). It assumes each script is its own bash script in the top-level of the `scripts` directory (no sub-folders). It stores all results in the `output` folder. Additionally, it reports on stdout which scripts succeeded and which failed (if the script failed, it also prints to stdout the stdout and stderr of the script that failed). Additionally, if the `config.json` file exists, `runner.sh` will use the values in it to send an email of the summary to an email address (refer to the `config.json.tmpl` file to see which keys/values are needed). It is up to each script in the `scripts` directory to report success/failure. `runner.sh` runs the tests in parallel up to the value of the `max_dop` variable at the top of `runner.sh`. The `lock` directory is temporarily created and deleted as a synchronization mechanism to make sure the outputs from each script don't get mixed up. If you kill `runner.sh` mid-run, this `lock` directory might stick around, in which case you will need to delete it before the next run.


# How To Use

## Set Up Send Grid (Optional)

If you do not wish to be emailed the results of the tests, then you can skip to the next section.

If, however, you wish to be emailed the results of the tests, you must first install the sendgrid python sdk with a command like `sudo pip install sendgrid`. Then, [set up a sendgrid account](https://docs.microsoft.com/azure/app-service-web/sendgrid-dotnet-how-to-send-email). Finally, copy the `config.json.tmpl` file to a file named `config.json` and put the necessary values in `config.json`.

## Set Up Tests

Upon first cloning/downloading this repo, run `bash setup.sh` to create the necessary folder structure. 

Copy whatever scripts you wish to test into the scripts directory (no sub-folders). If you don't have scripts to test but wish to see the behavior of `runner.sh`, you can simply use the `should_succeed.sh` and `should_fail.sh` scripts that come by default in the `scripts` directory.

Run `bash runner.sh`. This will output the test results, and if you set up send grid it will also print out the status of its attempt to send the email (http status 202 indicates that it successfully asked sendgrid to send the email, but sendgrid could still fail to send the email).

## Clean Up

Running `bash cleanup.sh` will delete the outputs of previous runs of runner.sh and remove the temporary lock directory if it exists.


# Example

Here is a repo with scripts to test scale set scenarios: https://github.com/gatneil/vmssScenarios.

Let's say we wish to set up a daily test of the scripts in the master branch of this repo. To do this, we could do the following:

First, we would follow the "How To Use" instructions above to set up the E2E Runners test framework. Then, we would define the following script that dowloads the master branch, copies the scripts to the E2E Runners `scripts` directory, then runs `runner.sh`:

```
# cd into a working directory that will be easy to clean up later
cd WORKING_DIR

# get the latest code in the master branch and run the tests
wget https://github.com/gatneil/vmssScenarios/archive/master.zip
unzip master.zip
cp vmssScenarios-master/* PATH_TO_E2E_RUNNERS_DIR/scripts/
cd PATH_TO_E2E_RUNNERS_DIR
bash runner.sh

# clean up working directory
rm WORKING_DIR/master.zip
rm -rf WORKING_DIR/vmssScenarios-master
```

Let's say this file is called `test_vmss_scenarios.sh` and is stored in WORKING_DIR. To run this daily, we could create a crontab entry like this:

```
0 14 * * * bash WORKING_DIR/test_vmss_scenarios.sh
```

This will run the tests at 1400 hours UTC (early morning US Pacific time) and report the results to us :).