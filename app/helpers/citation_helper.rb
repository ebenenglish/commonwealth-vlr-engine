# helper methods for rendering citations

module CitationHelper

  # an array of available citation formats
  # for each style, there should be a corresponding "render_#{style}_citation" method
  def citation_styles
    %w(mla apa chicago)
  end

  def render_citations(documents, citation_styles)
    citation_output_for_view = []
    citation_styles.each do |style|
      citation_output_for_view << content_tag(:h4, t("blacklight.citation.#{style}"))
      documents.each do |document|
        citation_output_for_view << content_tag(:div,
                                              render_citation(document, style).html_safe,
                                              class: 'citation-content')
      end
    end
    citation_output_for_view.join("\n").html_safe
  end

  def render_citation(document, citation_style)
    if citation_styles.include?(citation_style)
      public_send("render_#{citation_style}_citation", document)
    end
  end

  def render_mla_citation(document)
    citation_output = ''
    citation_output << names_for_citation(document, 'mla').presence.to_s
    citation_output << title_for_citation(document, 'mla')
    citation_output << publishing_data_for_citation(document).presence.to_s
    citation_output << if document[:date_start_tsim]
                         date_for_citation(document[:date_start_tsim].first, 'mla')
                       else
                         'n.d. '
                       end
    citation_output << "Web. #{Date.today.strftime('%d %b %Y')}. "
    citation_output << "&lt;#{url_for_citation(document)}&gt;."
    citation_output.gsub(/\.\./,'.')
  end

  def render_apa_citation(document)
    citation_output = ''
    names = names_for_citation(document, 'apa')
    citation_output << names if names
    title_date_info = []
    title_date_info << if document[:date_start_tsim]
                         date_for_citation(document[:date_start_tsim].first, 'apa')
                       else
                         '(n.d.). '
                       end
    title_date_info << title_for_citation(document, 'apa')
    if document[:genre_basic_ssim]
      title_date_info[1] = title_date_info[1].insert(-3, " [#{genre_for_citation(document[:genre_basic_ssim].first)}]")
    end
    title_date_info.reverse! unless names
    citation_output << title_date_info.join('')
    citation_output << "Retrieved from #{url_for_citation(document)}"
    citation_output.gsub(/\.\./,'.')
  end

  def render_chicago_citation(document)
    citation_output = ''
    citation_output << names_for_citation(document, 'chicago').presence.to_s
    citation_output << title_for_citation(document, 'chicago')
    citation_output << "#{genre_for_citation(document[:genre_basic_ssim].first)}. " if document[:genre_basic_ssim]
    citation_output << publishing_data_for_citation(document).presence.to_s
    citation_output << "#{render_mods_date(document[:date_start_tsim].first)}. " if document[:date_start_tsim]
    citation_output << "<em>#{t('blacklight.application_name')}</em>, "
    citation_output << "#{url_for_citation(document)} "
    citation_output << "(accessed #{Date.today.strftime('%B %d, %Y')})."
    citation_output.gsub(/\.\./,'.')
  end

  # create a list of creator names
  def names_for_citation(document, citation_style)
    name_and = citation_style == 'apa' ? '&' : 'and'
    return unless document[:name_personal_tsim] || document[:name_corporate_tsim] || document[:name_generic_tsim]
    names = []
    if document[:name_personal_tsim] || document[:name_generic_tsim]
      non_corp_names = document[:name_personal_tsim].presence.to_a.concat(document[:name_generic_tsim].presence.to_a)
      non_corp_names.map! { |pers_name| pers_name.gsub(/, [[d\.][ca\.][b\.] ]*\d.*/,'') }
      # for APA, names should be "Lastname, F." format
      if citation_style == 'apa'
        non_corp_names = non_corp_names.map do |pers_name|
          if pers_name.match(/\A[\w\-']*, [A-Z]/)
            "#{pers_name.match(/\A[\w\-']*, [A-Z]/).to_s}."
          else
            pers_name
          end
        end
      end
      # for MLA and Chicago, last personal name in list should be "Firstname Lastname" format
      if (citation_style == 'mla' || citation_style == 'chicago') && !document[:name_corporate_tsim] && non_corp_names.length > 1
        non_corp_names[-1] = non_corp_names.last.split(', ').reverse.join(' ')
      end
      names.concat(non_corp_names)
    end
    names.concat(document[:name_corporate_tsim]) if document[:name_corporate_tsim]
    # if multiple creators, put ', ' between each, but ', and/& ' before last one
    name_output = ''
    if names.length > 1
      0.upto names.length-1 do |index|
        if index == names.length-1
          name_output << "#{name_and} #{names[index]}"
        else
          name_output << "#{names[index]}, "
        end
      end
    else
      name_output << names.first
    end
    "#{name_output}. "
  end

  # return the publication info
  def publishing_data_for_citation(document)
    return unless document[:pubplace_tsim] || document[:publisher_tsim]
    publishing_output = ''
    publishing_output << document[:pubplace_tsim].first if document[:pubplace_tsim]
    publishing_output << ': ' if document[:pubplace_tsim] && document[:publisher_tsim]
    publishing_output << document[:publisher_tsim].first if document[:publisher_tsim]
    publishing_output.gsub!(/[\[\]]/,'')
    if document[:date_start_tsim]
      "#{publishing_output}, "
    else
      "#{publishing_output}. "
    end
  end

  # return date with formatting
  def date_for_citation(date_start, citation_style)
    date_components = date_start.split('-')
    if citation_style == 'mla'
      date_components[1] = Date::ABBR_MONTHNAMES[date_components[1].to_i] if date_components[1]
      "#{date_components.reverse.join(' ')}. "
    elsif citation_style == 'apa'
      apa_date_raw = date_components[0]
      apa_date_raw << ", #{Date::MONTHNAMES[date_components[1].to_i]}" if date_components[1]
      apa_date_raw << " #{date_components[2].to_i.to_s}" if date_components[2]
      "(#{apa_date_raw}). "
    end
  end

  # return the document title with formatting
  def title_for_citation(document, citation_style)
    if citation_style == 'mla'
      "<em>#{document[blacklight_config.index.title_field.to_sym]}</em>. "
    elsif citation_style == 'chicago'
      "\"#{document[blacklight_config.index.title_field.to_sym]}.\" "
    else
      "#{document[blacklight_config.index.title_field.to_sym]}. "
    end
  end

  # return the genre as a singular value
  def genre_for_citation(genre)
    genre.gsub(/s\z/,'')
  end

  # return the URL for the current page
  # prefer ARK when available
  def url_for_citation(document)
    if document[blacklight_config.show.display_type_field.to_sym] == 'OAIObject'
      solr_document_url(document)
    else
      document[:identifier_uri_ss].presence || solr_document_url(document)
    end
  end

end
