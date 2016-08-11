module CommonwealthVlrEngine
  module DownloadsHelperBehavior

    def create_download_links(document, files_hash, link_class)
      other_file_types = [files_hash[:audio], files_hash[:documents], files_hash[:ereader], files_hash[:generic]]
      download_links = []
      download_links.concat(image_download_links(files_hash[:images], link_class)) if files_hash[:images]
      other_file_types.each do |file_type|
        file_type.each do |file|
          object_profile_json = JSON.parse(file['object_profile_ssm'].first)
          file_name_ext = object_profile_json["objLabel"].split('.')
          download_link_title = document['identifier_ia_id_ssi'] ? ia_download_title(file_name_ext[1]) : file_name_ext[0]
          download_links << link_to(download_link_title,
                                    datastream_disseminator_url(file['id'],'productionMaster'),
                                    :target => '_blank',
                                    :class => link_class) + content_tag(:span,
                                                                        "(#{file_name_ext[1].upcase}, #{number_to_human_size(object_profile_json["datastreams"]["productionMaster"]["dsSize"])})",
                                                                        :class => 'download_info')
        end
      end
      download_links
    end

    def has_downloadable_files? document, files_hash
      has_downloadable_images?(document, files_hash) ||
          files_hash[:documents].present? ||
          files_hash[:audio].present? ||
          files_hash[:generic].present? ||
          files_hash[:ereader].present?
    end

    def has_downloadable_images? document, files_hash
      has_image_files?(files_hash) && license_allows_download?(document)
    end

    # render the file type names for Internet Archive book item download links
    def ia_download_title(file_extension)
      case file_extension
        when 'mobi'
          'Kindle'
        when 'zip'
          'Daisy'
        when 'pdf'
          'PDF'
        when 'epub'
          'EPUB'
        else
          file_extension.upcase
      end
    end

    def image_download_links(image_files_hash, link_class)
      case image_files_hash.length
        when 1
          object_profile_json = JSON.parse(image_files_hash.first['object_profile_ssm'].first)
          render_single_image_download_links(image_files_hash.first['id'], object_profile_json, link_class)
        else
      end
    end

    # parse the license statement and return true if image downloads are allowed
    def license_allows_download? document
      document[:license_ssm].to_s =~ /Creative Commons/ || document[:license_ssm].to_s =~ /No known restrictions/
    end

    def render_full_image_link(image_pid, object_profile_json, link_class)
      file_type = 'JPEG'
      link_to(file_type,
              iiif_image_url(image_pid,{}),
              :target => '_blank',
              :class => link_class) + content_tag(:span,
                                                  "(#{file_type}, #{number_to_human_size(object_profile_json["datastreams"]["productionMaster"]["dsSize"])})",
                                                  :class => 'download_info')
    end

    def render_large_image_link(image_pid, object_profile_json, link_class)
      file_type = object_profile_json["datastreams"]["access800"]["dsMIME"].split('/')[1].upcase
      link_to(file_type,
              datastream_disseminator_url(image_pid,'access800'),
              :target => '_blank',
              :download => 'WHATEVER.JPEG',
              :class => link_class) + content_tag(:span,
                                                  "(#{file_type}, #{number_to_human_size(object_profile_json["datastreams"]["access800"]["dsSize"])})",
                                                  :class => 'download_info')
    end

    def render_master_image_link(image_pid, object_profile_json, link_class)
      file_type = object_profile_json["datastreams"]["productionMaster"]["dsMIME"].split('/')[1].upcase
      link_to(file_type,
              datastream_disseminator_url(image_pid,'productionMaster'),
              :download => 'WHATEVER.TIFF',
              :target => '_blank',
              :class => link_class) + content_tag(:span,
                                                  "(#{file_type}, #{number_to_human_size(object_profile_json["datastreams"]["productionMaster"]["dsSize"])})",
                                                  :class => 'download_info')
    end

    def render_single_image_download_links(image_pid, object_profile_json, link_class)
      [render_master_image_link(image_pid, object_profile_json, link_class),
       render_full_image_link(image_pid, object_profile_json, link_class),
       render_large_image_link(image_pid, object_profile_json, link_class)]
    end

  end
end