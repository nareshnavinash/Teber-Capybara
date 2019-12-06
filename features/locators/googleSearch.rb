module Locators
    class GoogleSearch < SitePrism::Page
        
      element :search_textbox, 'input[name="q"]'
      element :search_box, 'div[jsname="VlcLAe"] input[name="btnK"]'
      element :after_search_image, 'div.logo img[alt*="Google"]'
      element :after_search_image_custom, 'div.logo img[alt*="{name}"]'

    end
  end
  