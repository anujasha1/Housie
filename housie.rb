# Housie Ticket Generator
module Housie
  def self.generate_and_print_ticket
    col_counts = distribute_counts_across_columns
    occupancy = assign_rows_for_columns(col_counts)
    grid      = fill_numbers(occupancy)
    print_grid(grid)
  end

  private

  # Sum of all the numbers must be 15, so deciding here the umbers in columns
  def self.distribute_counts_across_columns
    counts = Array.new(9, 1)
    remaining = 15 - counts.sum
    while remaining > 0
      idx = rand(9)
      if counts[idx] < 3
        counts[idx] += 1
        remaining -= 1
      end
    end

    counts.shuffle
  end

  #assiging rows to each column based on the its count
  def self.assign_rows_for_columns(col_counts)
    occupancy = Array.new(3) { Array.new(9, false) }
    row_counts = Array.new(3, 0)
    order = (0...9).to_a.shuffle

    success = backtrack_assign(0, order, col_counts, occupancy, row_counts)
    raise "Failed to assign rows. Try again." unless success
    occupancy
  end

  def self.backtrack_assign(pos, order, col_counts, occupancy, row_counts)
    return row_counts.all? { |c| c == 5 } if pos == order.length

    col_index = order[pos]
    needed = col_counts[col_index]
    combinations([0,1,2], needed).shuffle.each do |combo|
      new_row_counts = row_counts.dup
      combo.each { |r| new_row_counts[r] += 1 }
      next if new_row_counts.any? { |c| c > 5 }

      remaining_cols = order.length - (pos + 1)
      next if new_row_counts.any? { |c| c + remaining_cols < 5 }

      combo.each { |r| occupancy[r][col_index] = true }
      combo.each { |r| row_counts[r] += 1 }

      return true if backtrack_assign(pos + 1, order, col_counts, occupancy, row_counts)

      combo.each { |r| occupancy[r][col_index] = false }
      combo.each { |r| row_counts[r] -= 1 }
    end
    false
  end

  def self.combinations(arr, k)
    return [[]] if k == 0
    return arr.map { |x| [x] } if k == 1
    return [arr] if k == arr.length
    result = []
    arr.each_with_index do |el, idx|
      rest = arr[(idx+1)..-1] || []
      combinations(rest, k-1).each { |s| result << ([el] + s) }
    end
    result
  end

  # Showing the numbers in grid
  def self.fill_numbers(occupancy)
    grid = Array.new(3) { Array.new(9, nil) }
    (0...9).each do |col|
      rows_with_number = (0...3).select { |r| occupancy[r][col] }
      count = rows_with_number.size

      low  = (col == 0) ? 1 : col*10
      high = (col == 8) ? 90 : col*10+9
      numbers = (low..high).to_a.sample(count).sort

      rows_with_number.sort.each_with_index do |r, idx|
        grid[r][col] = numbers[idx]
      end
    end
    grid
  end

  #Printing it like real ticket
  def self.print_grid(grid)
    puts "+----+----+----+----+----+----+----+----+----+"
    (0...3).each do |r|
      row_str = grid[r].map { |cell| cell.nil? ? " X  " : sprintf("%3d ", cell) }.join("|")
      puts "|" + row_str + "|"
      puts "+----+----+----+----+----+----+----+----+----+"
    end
  end
end

if __FILE__ == $0
  Housie.generate_and_print_ticket
end
