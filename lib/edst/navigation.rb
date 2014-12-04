module EDST
  module Navigation
    def self.generate(edsts, options = {})
      data = {}

      chapter_per_cluster_n = options.fetch(:chapter_per_cluster_n, 6)
      basename_fmt = options.fetch(:basename_fmt, 'ch%03d')

      edsts.each do |filename|
        i = filename.match(/ch(\d+)/)[1].to_i
        first = i % chapter_per_cluster_n == 0
        last = i % chapter_per_cluster_n == (chapter_per_cluster_n-1)
        cluster = (i-1) / chapter_per_cluster_n
        chapter = i
        chapter_for_cluster = cluster * chapter_per_cluster_n + 1
        chapter_for_next_cluster = (cluster+1) * chapter_per_cluster_n + 1
        chapter_for_prev_cluster = (cluster-1) * chapter_per_cluster_n + 1
        chapter_for_next_cluster = nil unless chapter_for_next_cluster < edsts.size
        chapter_for_prev_cluster = nil if chapter_for_prev_cluster < 1

        next_chapter = chapter + 1
        prev_chapter = chapter - 1
        next_chapter = nil unless next_chapter < edsts.size
        prev_chapter = nil if prev_chapter < 1

        data[chapter] = {
          id: chapter,
          cluster: cluster+1,
          basename: basename_fmt % chapter,
          next: next_chapter,
          next_cluster: chapter_for_next_cluster,
          prev: prev_chapter,
          prev_cluster: chapter_for_prev_cluster,
        }
      end
      data
    end
  end
end
