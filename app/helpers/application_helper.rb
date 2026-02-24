module ApplicationHelper
  def format_currency(amount)
    return "$0.00" if amount.nil?
    "$#{'%.2f' % amount.to_f}"
  end

  def status_badge(status)
    classes = case status
              when "pending"   then "bg-warm-100 text-warm-700"
              when "extracted" then "bg-blue-100 text-blue-700"
              when "confirmed" then "bg-green-100 text-green-700"
              else "bg-warm-100 text-warm-700"
              end
    "<span class=\"inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold #{classes}\">#{status.capitalize}</span>".html_safe
  end

  def designation_badge(designation)
    classes = designation == "business" ? "bg-warm-100 text-warm-700" : "bg-gray-100 text-gray-600"
    "<span class=\"inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold #{classes}\">#{designation.capitalize}</span>".html_safe
  end

  def category_label(key)
    return "—" if key.blank?
    key.titleize
  end
end
