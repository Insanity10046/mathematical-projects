p = 1;
function result = parse_statement(statement)
  s = strrep(statement, ' ', '');
  subexprs = {};
  for i = 1:length(s)
    if s(i) == '('
      stack = 0;
      for j = i:length(s)
        if s(j) == '('
          stack = stack + 1
        elseif s(j) == ')'
          stack = stack - 1;
          if stack == 0
            subexprs{end+1} = s(i:j);
            break;
          endif
        endif
      endfor
    endif
  endfor
  result = unique(subexprs);
  [~, idx] = sort(cellfun(@(s) sum(s == '(') + sum(s == ')'), result));
  result = result(idx);
endfunction;

function result = understand_statement(logic, variables, truth_table, current_row)
  # variables - holds truth value
  # logic - logical statements
  amount_of_variables = length(variables);
  expression = logic;
  for j = 1:length(variables)
    expression = strrep(expression, variables(j), num2str(truth_table(current_row, j)));
  endfor

  #expression = regexprep(expression, '[()]', '');
  expression = strrep(expression, '∧', '&');
  expression = strrep(expression, '∨', '|');
  expression = strrep(expression, '¬', '~');
  expression = strrep(expression, '→', '<= ');
  expression = strrep(expression, '⇒', '<= ');
  expression = strrep(expression, '↔', '==');
  disp(expression);
  result = eval(expression);

endfunction

function truth_table = calculate_truth_table(variables, logical_statements, statement)
  n = length(variables) + length(logical_statements);
  number_of_combinations = 2^length(variables);
  truth_table = zeros(number_of_combinations, n);

  for i=1:number_of_combinations-1
    binary_str = dec2bin(i, length(variables));
    for j = 1:length(variables)
      truth_table(i, j) = str2double(binary_str(j));;
    endfor
    expression = statement;
  endfor

  for i=1:number_of_combinations
    itr_stat = 0;
    for j = length(variables)+1:number_of_combinations
      # analyse each logical statement
      itr_stat++;
      #disp(length(logical_statements));
      if itr_stat > length(logical_statements)
        itr_stat = length(logical_statements);
      endif
      truth_table(i, j) = understand_statement(logical_statements{1, itr_stat}, variables, truth_table, i);
      #break;
    endfor
    #break;
  endfor
endfunction;

function result = logic_reader(statement)
  variables = unique(statement(statement >= 'A' & statement <= 'Z'));
  logical_statements = parse_statement(statement);
  logical_statements{1, length(logical_statements)+1} = statement;
  disp(logical_statements);
  # create the truth table
  n = (length(variables) + length(logical_statements));
  truth_table = calculate_truth_table(variables, logical_statements, statement);
  #disp(logical_statements);
  fprintf('\nTruth Table for: %s\n', statement);
  fprintf('%-6s', strjoin(cellstr(variables'), '      '));
  fprintf('%-6s', strjoin(cellstr(logical_statements'), '      '));
  #fprintf('    %6s\n', statement);
  fprintf('%s\n', repmat('-', 1, 6*(n+1)));
  for i = 1:2^length(variables)
    for j = 1:n
      fprintf('%-6d  ', truth_table(i, j));
    endfor
    fprintf('%-6d\n', truth_table(i, n));
  endfor
  # calculate the truth table of the statement


endfunction;

logic_reader('((P∧Q)⇒(R∨S)) ⇒ ((P⇒R)∧(Q⇒S))'); #(P⇒(Q⇒R))⇒(Q⇒(P⇒R))
