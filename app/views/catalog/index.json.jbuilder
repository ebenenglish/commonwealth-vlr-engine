# frozen_string_literal: true

# This override drastically reduces the size of responses and improves their readability.
# Data from the "included" facets and the "mods_xml_ss" field is unlikely to be useful for downstream users/apps.

json.links do
  json.self url_for(search_state.to_h.merge(only_path: false))
  json.prev url_for(search_state.to_h.merge(only_path: false, page: @response.prev_page.to_s)) if @response.prev_page
  json.next url_for(search_state.to_h.merge(only_path: false, page: @response.next_page.to_s)) if @response.next_page
  json.last url_for(search_state.to_h.merge(only_path: false, page: @response.total_pages.to_s))
end

json.meta do
  json.pages @presenter.pagination_info
end

json.data do
  json.array! @presenter.documents do |document|
    doc_presenter = document_presenter(document)
    document_url = Deprecation.silence(Blacklight::UrlHelperBehavior) { polymorphic_url(url_for_document(document)) }
    json.id document.id
    json.type doc_presenter.display_type.first
    json.attributes do
      # Removes 'mods_xml_ss' field from the response
      fields_to_render = doc_presenter.fields_to_render.reject { |field_name, _, _| field_name == 'mods_xml_ss' }
      fields_to_render.each do |field_name, field, field_presenter|
        json.partial! 'field', field: field,
                               field_name: field_name,
                               document_url: document_url,
                               doc_presenter: doc_presenter,
                               field_presenter: field_presenter,
                               view_type: 'index'
      end
    end

    json.links do
      json.self document_url
    end
  end
end

# json.included do
#   json.array! @presenter.search_facets do |facet|
#     json.type 'facet'
#     json.id facet.name
#     json.attributes do
#       facet_config = facet_configuration_for_field(facet.name)
#       json.label facet_field_label(facet_config.key)
#       json.items do
#         json.array! facet.items do |item|
#           json.id
#           json.attributes do
#             json.label item.label
#             json.value item.value
#             json.hits item.hits
#           end
#           json.links do
#             Deprecation.silence(Blacklight::FacetsHelperBehavior) do
#               if facet_in_params?(facet.name, item.value)
#                 Deprecation.silence(Blacklight::SearchState) do
#                   json.remove search_action_path(search_state.remove_facet_params(facet.name, item.value))
#                 end
#               else
#                 json.self path_for_facet(facet.name, item.value, only_path: false)
#               end
#             end
#           end
#         end
#       end
#     end
#     json.links do
#       json.self search_facet_path(id: facet.name, only_path: false)
#     end
#   end

#   json.array! search_fields do |(label, key)|
#     json.type 'search_field'
#     json.id key
#     json.attributes do
#       json.label label
#     end
#     json.links do
#       json.self url_for(search_state.to_h.merge(search_field: key, only_path: false))
#     end
#   end

#   json.array! active_sort_fields do |key, field|
#     json.type 'sort'
#     json.id key
#     json.attributes do
#       json.label field.label
#     end
#     json.links do
#       json.self url_for(search_state.to_h.merge(sort: key, only_path: false))
#     end
#   end
# end
