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
         %конструктор класса
         function obj = HungarianMethod(m)
            obj.matrix = m;
            obj.rows = zeros(length(m), 1);
            obj.cols = zeros(length(m), 1);
            obj.marked = zeros(length(m));
            obj.lpath = zeros(2*length(m), 2);    
            obj.count = 0;
         end
         
        %предобработка матрицы (вычитание наименьших элементов)
        function obj = preprocessing(obj)
            m = obj.matrix';
            %вычесть минимум из каждого столбца
            for i = 1:length(m)
                m(i, :) = m(i, :) - min(m(i, :));
            end
            m = m';
            
            %вычесть минимум из каждой строки
            for i = 1:length(m)
                m(i, :) = m(i, :) - min(m(i, :));
            end
            
            obj.matrix = m;
        end
        
        %создание системы независимых нулей
        function obj = coverage(obj)
            
            %поиск всех нулей
            [ii, jj] = find(~obj.matrix);
            
            %создание системы независимых нулей
            for i = 1:length(jj)
                %если нет нуля с * в столбце и строке
                if obj.cols(jj(i)) == 0 && obj.rows(ii(i)) == 0
                    obj.rows(ii(i)) = 1;
                    obj.cols(jj(i)) = 1;
                    obj.marked(ii(i), jj(i)) = 1;
                    obj.count = obj.count + 1;
                end
            end
            
            %очистить все отметки
            obj.rows = zeros(length(obj.matrix), 1);
            obj.cols = zeros(length(obj.matrix), 1);
            
            %если вдруг была создана система независимых нулей
            %то заканчиваем
        end
        
        %создание альтернативной системы независимых нулей
        %добавляет один нуль за раз в систему независимых нулей
        function obj = alternate_coverage(obj)
            %проверяем есть ли среди непокрытых элементов нули 
            
            %создаем отметки
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                    if obj.marked(i, j) == 1
                        obj.cols(j) = 1;
                        obj.rows(i) = 1;
                    end
                end
            end
            
            zeros = 0;
            minval = Inf;
            %смотрим есть ли в непокрытых элементах нули
            
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                    %элемент не отмечен и есть нуль
                    if obj.rows(i) == 0 && obj.cols(j) == 0
                       if  obj.matrix(i, j) == 0
                        zeros = zeros + 1;
                       else
                           if obj.matrix(i, j) < minval
                               minval = obj.matrix(i, j);
                           end
                       end
                    end
                end
            end
            
            %если среди непокрытых элементов нет нулей
            %создаем нули
            if zeros == 0
                %из всех 
                for i = 1:length(obj.matrix)
                    
                end
            end
            
        end
        
    end
end
