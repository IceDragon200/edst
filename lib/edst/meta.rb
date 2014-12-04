require 'edst/convert/edst_to_h'

module EDST
  module Meta
    def self.split_csv(str)
      str.gsub(/\s+/, '').split(',')
    end

    def self.generate_from_data(data)
      book = data['book']

      book['number'] = book['number'].to_i
      book['length'] = book['length'].to_i

      book['chapter_map'] = {}
      book['cluster_map'] = {}

      arcs = book['arcs']
      arcs.each do |arc_id, value|
        value['clusters'].each do |cluster_id, cluster|
          unless cluster.is_a?(Hash)
            abort "ERROR: Invalid cluster #{cluster_id}, cluster is not a dict (aka. ruby Hash)"
          end
          if cluster.has_key?('chapters')
            if book['cluster_map'].has_key?(cluster_id)
              warn "WARNING: cluster #{cluster_id} duplicate found"
            end
            cluster['chapters'] = split_csv cluster['chapters']
            cluster['chapters'].each do |chapter_id|
              book['chapter_map'][chapter_id] = {
                'id' => chapter_id,
                'arc' => arc_id,
                'cluster' => cluster_id
              }
            end
            cluster['arc'] = arc_id
            book['cluster_map'][cluster_id] = cluster
          else
            warn "WARNING: cluster #{cluster_id} does not have any chapters"
          end
        end
        value['chapters'] = value['clusters'].values.map do |h|
          h['chapters']
        end.flatten
        value['clusters'] = value['clusters'].keys
      end

      data
    end

    def self.generate_from_string(string)
      generate_from_data(EDST.edst_to_h(string))
    end

    def self.generate_from_file(filename)
      generate_from_string(File.read(filename))
    end
  end
end
