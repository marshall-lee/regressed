module FileOperations
  def insert_line(path, number, line)
    File.open(File.join(repo.workdir, path), 'r+') do |f|
      lines = f.readlines
      lines.insert number - 1, "#{line}\n"
      f.truncate 0
      f.seek 0
      f.write lines.join
    end
  end

  def change_line(path, number, line)
    File.open(File.join(repo.workdir, path), 'r+') do |f|
      lines = f.readlines
      lines[number - 1] = "#{line}\n"
      f.truncate 0
      f.seek 0
      f.write lines.join
    end
  end

  def delete_line(path, number)
    File.open(File.join(repo.workdir, path), 'r+') do |f|
      lines = f.readlines
      lines.delete_at number - 1
      f.truncate 0
      f.seek 0
      f.write lines.join
    end
  end
end
