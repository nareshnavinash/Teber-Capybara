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
  