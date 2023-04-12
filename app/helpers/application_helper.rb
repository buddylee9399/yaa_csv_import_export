module ApplicationHelper

def menu_items
  [{
    name: 'Home',
    path: root_path,
  }, {
    name: 'About',
    path: about_path,
  }, {
    name: 'Contact',
    path: contact_path,
  }, {
    name: 'Privacy',
    path: privacy_path,
  },].map do |item|
    {
      name: item[:name],
      path: item[:path],
      active: current_page?(item[:path])
    }
  end
end

end
