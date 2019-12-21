require "all_companies/version"
require "faraday"
require "nokogiri"

module AllCompanies
  class Error < StandardError; end

  class Finder
    @@base_url = "https://www.builtincolorado.com"

    def self.find
      html = Faraday.get("#{@@base_url}/companies?status=all")
      doc = Nokogiri::HTML(html.body)
      companies = []
      doc.css('.company-filtered-card > .wrap-view-page > a').each do |row|
        relative_path = row.attributes["href"].value
        company_url = @@base_url + relative_path
        company_page = Faraday.get(company_url)
        company_info = Nokogiri::HTML(company_page.body)
        name = company_info
          .css(".company-card-title > h1")
          .first
          .children
          .text
        local_employees = company_info
          .css(".field_local_employees > .item")
          .first
          .children
          .text
        total_employees = company_info
          .css(".field_total_employees > .item")
          .first
          .children
          .text if company_info.css('.field_total_employees > .item').first
        address = company_info
          .css(".gmap_location_widget, .company_location")
          .first
          .children[1]
          .attributes["src"]
          .value.split("q=")[1]
          .gsub("+", " ")
        jobs = company_info
          .css('#bix-companies-open-jobs > .view-content .title > a')
        jobs_info = []
        jobs.each do |job|
          title = job.text
          link = job.attributes['href'].value
          jobs_info << {title: title, link: @@base_url + link}
        end
        company = {
          name: name,
          local_employees: local_employees,
          total_employees: total_employees,
          address: address,
          jobs: jobs_info
        }
        companies << company
#         first_job_title = company_info
#           .css('#bix-companies-open-jobs > .view-content .title > a')
#           .first
#           .text
#         first_job_link = @@base_url + company_info
#           .css('#bix-companies-open-jobs > .view-content .title > a')
#           .first
#           .attributes['href']
#           .value
      end
      require 'pry'; binding.pry
      companies
    end
  end
end
