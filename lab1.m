function lab1
    matrix = magic(5);
    preprocessing(matrix);
end

function m = preprocessing(m0)
    m = m0;
    
    m = m';

    % вычесть минимум из каждого столбца
    for i = 1:5
        display(min(m(i, :)));
        m(i, :) = m(i, :) - min(m(i, :));
    end
    m = m';
    
    %вычесть минимум из каждой строки
    for i = 1:5
        m(i, :) = m(i, :) - min(m(i, :));
    end
    
end
