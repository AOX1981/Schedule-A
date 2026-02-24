module ApplicationHelper
  def format_currency(amount)
    return "$0.00" if amount.nil?
    "$#{'%.2f' % amount.to_f}"
  end

  def status_badge(status)
    klass = case status
            when "pending" then "badge-pending"
            when "extracted" then "badge-extracted"
            when "confirmed" then "badge-confirmed"
            else "badge-pending"
            end
    "<span class=\"badge #{klass}\">#{status.capitalize}</span>".html_safe
  end

  def designation_badge(designation)
    klass = designation == "business" ? "badge-business" : "badge-personal"
    "<span class=\"badge #{klass}\">#{designation.capitalize}</span>".html_safe
  end

  def category_label(key)
    return "—" if key.blank?
    key.titleize
  end
end
