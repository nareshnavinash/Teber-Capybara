# Teber-Capybara

Teber-Capybara is a Page Object Model (POM) framework for selenium automation with ruby `Cucumber` in `Capybara`. In order to make the testing faster used 'parallel_tests' gem to run multiple threads to run the tests at the same time. For reporting 'allure' is being adapted.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Made with Ruby](https://img.shields.io/badge/Made%20with-Ruby-red.svg)](https://www.ruby-lang.org/en/)
[![StackOverflow](http://img.shields.io/badge/Stack%20Overflow-Ask-blue.svg)]( https://stackoverflow.com/users/10505289/naresh-sekar )
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)
[![email me](https://img.shields.io/badge/Contact-Email-green.svg)](mailto:nareshnavinash@gmail.com)


![alt text](features/libraries/Teber_Capybara.png)


## Supports
* Multiple browser automation
* Multi browser automation
* Allure reports
* Jenkins Integration
* Modes of run via CLI command
* Headless run
* Docker Execution
* Failed Screenshots
* Testdata driven tests
* Multi Thread run

## Setup
* Clone this repository
* Navigate to the cloned folder
* Install bundler using `gem install bundler`
* Install the dependencies by `bundle install`

## To Run the tests
For a simple run of all the feature files in normal mode, try
```
cucumber
```
To Run the tests in parallel mode for the available feature files, try

```
parallel_cucumber features/ 
```
To Run the tests in parallel mode for the available feature files along with tags, try
```
parallel_cucumber features/ -o "-t "@scenario_001""
```
To Run the tests in parallel mode for the available feature files along with tags and environment variables, try
```
parallel_cucumber features/ -o "-t "@scenario_001" MODE=headless"
```
This will run the tests in headless mode

## To open allure results
```
allure serve reports/allure
```

## Multiple Browser
Currently supports for Chrome browser, but handled in such a way that framework can be easily configured to support multiple browsers. I used webdriver manager to resolve the driver-browser compatibility issues, use the same to add your designated browser (firefox, edge, ie, safari etc.,).

## Multi Browser
Initiate the driver class inside support package mutiple times with different WebDriver objects. You can execute the actions in multiple browsers at the same time by executing actions against each driver object.

## Reports
For better illustration on the testcases, allure reports has been integrated. Allure reports can also be integrated with jenkins to get a dashboard view. Apart from allure, cucumber's default reporting such as html, pretty, progress, rerun files has been added to the `reports/` folder.

## Jenkins Integration with Docker images
Get any of the linux with ruby docker image as the slaves in jenkins and use the same for executing the UI automation with this framework (Sample docker image - `https://hub.docker.com/_/ruby`). From the jenkins bash Execute the following to get the testcases to run,
```
#!/bin/bash -l
rvm list
ls
cd <path_to_the_project>
bundle install
cucumber #or custom commands
```
for complete guide to setup in linux check [Cloud Setup for Ruby](https://github.com/nareshnavinash/Cloud-Setup-Ruby)

In Jenkins pipeline, try to add the following snippet to execute the tests,
```
pipeline {
    agent { docker { image 'ruby' } }
    stages {
        stage('build') {
            steps {
                sh 'cd project/'
                sh 'gem install bundler'
                sh 'bundle install'
                sh 'cucumber' # or custom methods
            }
        }
    }
}
```

## Headless Run
In `global-data/global.yml` file, if the mode is `headless`, the chrome will be initialized in headless mode which can be used to run in server. Screenshots will be added even if the browser runs in headless mode.

## Failed Screenshots
To get the screenshots attached to allure reports have included a Class `Screenshots` in `Library` module. Since `attach_file` method is available in both Capybara and Allure, we need to have that patch to get the screenshots getting attached to the allure reports.

## Break down into end to end tests

### Adding Locators to the project

1. Add Locators to the that are going to be used inside the project inside the `Locators` module
```
module Locators
	# Add a class for each page and add the locators
end
```
2. For each page add a new class inside the `Locators` module. I included SitePrism to have page object model in Capybara. More info on SitePrism at [visit](https://github.com/site-prism/site_prism)

```
module Locators
  class GoogleSearch < SitePrism::Page
      
    element :search_textbox, 'input[name="q"]'
    element :search_box, 'div[jsname="VlcLAe"] input[name="btnK"]'
    element :after_search_image, 'div.logo img[alt*="Google"]'
    element :after_search_image_custom, 'div.logo img[alt*="{name}"]'

  end
end

```

3. Ideally each web page should have a new file inside locators folder (with the same name as the web page) and all the locators inside a web page has to be declared inside a page class(Class name also should be same as the web page name).
* If the web page name is `home page` then the locator file name should be `home_page.rb` inside `locators` folder and the class name should be `HomePage` inside `Locators` module.

### Adding page methods to the project

1. Add page specific methods inside the `Pages` module.

```
module Pages
  # add the page class here
end
```

2. For each page add a new class inside `Pages` module and each page class should inherit the locators class of the same page. You can directly use all the siteprism methods in the page module.

```
module Pages
    class GoogleSearch < Locators::GoogleSearch
  
      def initialize
        super()
      end
  
      def enter_text_and_search(string)
        wait_until_search_textbox_visible
        search_textbox.send_keys string
        wait_until_search_box_visible
        search_box.click
      end

      def is_results_page_displayed?
        wait_until_after_search_image_visible
      end

    end
  end
  
```

3. Ideally each web page should have a new page file inside `pages` folder with the class name same as the web page name.
* If the web page name is `home page` then the pages file name should be `home_page.rb` inside `pages` folder and the class name should be `HomePage` inside `Pages` module.

### Creating a new feature file in the project

1. Define the tests in the feature file in gherkin language.

```
Feature: Sample project setup
  To get to know the sample cucumber project

  Scenario: This test will pass
    Given true eql true
    When false eql false
    Then string eql string
```

2. Ideally tags has to be used for each feature and each scenario to identify the test cases in the unique way.

```
@before_feature @test_feature
Feature: Sample project setup
  To get to know about the basic flows in this framework

  @before_scenario @test_id=001
  Scenario: This test will pass
    Given true eql true
    When false eql false
    Then string eql string
```

3. Now declare the feature steps inside the step definitions file, the name of the step definition file should be same as the feature file.

4. In the step definitions file, initially declare the before and after action block.

```
Before do
  puts "before each "
end

After do |s|
   puts "after each "
end
```

5. Cucumber allows us to use in an extensive way. So we can define `Before` and `After` for each specific tags that we defined in the feature file.

```
Before('@test_tag') do
  puts "before each "
end

After('@test_tag') do |s|
   puts "after each "
end
```

6. Define the steps after the before/after block.

```
Given("true eql true") do
  expect(true).to eql true
end

When("false eql false") do
  expect(false).to eql false
end

Then("string eql string") do
  expect("test").to eql "test"
end
```

## Built With

* [Cucumber](https://rubygems.org/gems/cucumber/versions/3.1.2) - Automation core framework
* [Parallel_tests](https://rubygems.org/gems/parallel_tests) - To run automation parallely at the same time.
* [Allure Cucumber](https://rubygems.org/gems/allure-cucumber/versions/0.6.1) - For Detailed reporting.
* [Selenium](https://www.seleniumhq.org/) - For web browser automation.
* [Capybara](https://github.com/teamcapybara/capybara) - Wrapper for Selenium Webdriver.
* [Site_Prism](https://github.com/site-prism/site_prism) - To include Page Object Model in Capybara

## Contributing

1. Clone the repo!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a pull request.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on code of conduct, and the process for submitting pull requests.

## Authors

* **[Naresh Sekar](https://github.com/nareshnavinash)**

## License

This project is licensed under the GNU GPL-3.0 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* To all the open source contributors whose code has been referred in this project.
