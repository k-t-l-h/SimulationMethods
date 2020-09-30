classdef HungarianMethod
    properties
        %сама матрица
        matrix 
        %для строк без +
        rows
        %для столбцов без +
        cols
        %для построения l-цепочек
        lpath
        %для отметок для системы независимых нулей
        marked
        
        %счетчик СНН
        count
    end
    
    methods
        %предобработка матрицы (вычитание наименьших элементов)
        function m = preprocessing(matrix)
            m = matrix';
            %вычесть минимум из каждого столбца
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
        
        %создание системы независимых нулей
        function coverage(obj)
            
            %поиск всех нулей
            [ii, jj] = find(~obj.matrix);
            
            %создание системы независимых нулей
            for i = 1:length(jj)
                %если нет нуля с * в столбце и строке
                if obj.cols(jj(i)) == 0 && obj.rows(ii(ii)) == 0
                    obj.rows(ii(i)) = 1;
                    obj.cols(jj(i)) = 1;
                    obj.marked(ii(i), jj(i));
                    obj.count = obj.count + 1;
                end
            end
            
            %очистить все отметки
        end
        
    end
end



