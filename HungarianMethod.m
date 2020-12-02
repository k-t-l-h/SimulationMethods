classdef HungarianMethod
    properties
        %сама матрица
        matrix 
        %матрица для вывода
        cost
        %для строк без +
        rows 
        %для столбцов без +
        cols 
        %для построения l-цепочек
        lpath
        %для отметок * 
        marked 
        %для отметок '
        smarked
        %флаг задачи максимизации
        flag 
        %счетчик СНН
        count 
        %флаг для вывода промежуточных результатов
        debug
    end
    
    methods
         %конструктор класса
         function obj = HungarianMethod(m, maxFlag, debugFlag)
            obj.matrix = m;
            obj.cost = m;
            obj.marked = [];
            obj.smarked = [];
            obj.count = 0;
           
            obj.lpath = [];   
            obj.flag = maxFlag;
            obj.debug = debugFlag;
         end
         
         %проверка задачи и изменение матрицы
         %работает корректно
         function obj = start(obj)
             %если необходимо заменить задачу 
             %максимизации на задачу минимизации
             if obj.flag 
                 m_max = max(max(obj.matrix));
                 new_matrix = m_max - obj.matrix;
                 obj.matrix = new_matrix;
                
                 if obj.debug 
                     fprintf("Решается задача максимизации \n")
                     fprintf("Новая матрица: \n")
                     obj.printMatrix();
                     fprintf("\n");
                 end 
             else
                 if obj.debug 
                     fprintf("Исходная матрица: \n")
                     obj.printMatrix();
                     fprintf("\n");
                 end 
             end
         end
         
        %предобработка матрицы (вычитание наименьших элементов)
        %работает корректно
        function obj = preprocessing(obj)
            
            obj.matrix = obj.matrix';
            %вычесть минимум из каждого столбца
            for i = 1:length(obj.matrix)
                obj.matrix(i, :) = obj.matrix(i, :) - min(obj.matrix(i, :));
            end
            obj.matrix = obj.matrix';
           
            %вычесть минимум из каждой строки
            for i = 1:length(obj.matrix)
                obj.matrix(i, :) = obj.matrix(i, :) - min(obj.matrix(i, :));
            end
            
             if obj.debug            
                 fprintf("Минимизация матрицы \n")
                 fprintf("Новая матрица: \n")
                 obj.printMatrix();
                 fprintf("\n");
             end
                     
        end
        
        %создание системы независимых нулей
        %работает корректно
        function obj = coverage(obj)
            %проход по матрице
            
            %чтобы избежать выхода за пределы массива
            obj.marked = [obj.marked; [-1, -1]];
            
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                    %находим первый ноль в столбце
                    if obj.matrix(i, j) == 0 
                        if not(ismember(j, obj.marked(:, 2)))
                            obj.marked = [obj.marked; [i, j]];
                            break;
                        end
                    end
                end
            end
            
            %удаление фиктивного элемента
            obj.marked(1, :) = [];
            obj.count = 1;
            
             if obj.debug
                    fprintf("Итерация %d \n", obj.count);
                    obj.printIteration();
             end
        end
        
       %создание альтернативной системы независимых нулей
        function obj = alternate_coverage(obj)
            
            %добавление одного нуля в СНН
            %до тех пор, пока это необходимо
            while size(obj.marked,1) ~= size(obj.matrix, 1)
                obj.count = obj.count + 1;
                
                if obj.debug
                    fprintf("Итерация %d \n", obj.count);
                    obj.printIteration();
                end
                
                %заполнение отметок
                obj.cols = obj.marked(:,2);
                
                %заполнение отметок
                if size(obj.rows,1) == 0
                    obj.rows = [];
                else 
                    obj.rows = obj.smarked(:,1);
                end
                
                %обнуляем новые отметки
                obj.smarked = [];
                
                %есть ли неотмеченные нули
                [obj, flags, zi, zj] = obj.isNull();
                
                while true 
                    obj.count = obj.count + 1;
                    %если есть неотмеченный ноль
                    if flags
                        obj.smarked = [obj.smarked; [zi, zj]];
                        %есть ли второй ноль в строчке?
                        [obj, f, dc] = obj.doubleZero(zi);
                        
                        %если да, отмечаем его штрихом
                        if f == true
                            obj.rows = [obj.rows; zi ];
                            obj.cols(obj.cols == dc) = [];
                            
                            if obj.debug
                                fprintf("Итерация %d \n", obj.count);
                                obj.printIteration();
                            end
                        else
                            %если нет, строим L-цепочку
                            obj = obj.Lchain();
                            
                            for i = 1:size(obj.lpath,1)
                                [lr, lc] = ismember(obj.lpath(i, :), obj.marked, 'rows');
                                if lr
                                    obj.marked(lc, :) = [];
                                else
                                    obj.marked = [obj.marked; obj.lpath(i, :)];
                                end
                            end
                            obj.smarked = [];
                            obj.cols = [];
                            obj.rows = [];
                            
                            if obj.debug
                                fprintf("Итерация %d \n", obj.count);
                                obj.printIteration();
                            end
                            break;
                        end
                        [obj, flags, zi, zj] = obj.isNull();
                    else 
                    %если нет неотмеченных нулей
                    obj = obj.makeNulls();
                    
                    if obj.debug
                        fprintf("Итерация %d \n", obj.count);
                        obj.printIteration();
                    end
                    
                    [obj, flags, zi, zj] = obj.isNull();
                    end                
                   
                end
                
            end
        end
        
        
         %поиск первого неотмеченного нуля
        function [obj, flags, zi, zj] = isNull(obj)
            flags = false;
            zi = -1; 
            zj = -1;
            % поиск всех нулей
            %поиск первого нуля не в помеченных
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                    if ( obj.matrix(i, j) == 0 ...
                            && ~ismember(j, obj.cols) ...
                            && ~ismember(i, obj.rows))
                    zi = i;
                    zj = j;
                    flags = true;
                    return;
                    end                   
                end
            end           
        end
        
        
        %если нет нулей в неотмеченных элементах, то нужно создать
        %работает корректно 
        function obj = makeNulls(obj)          
            %поиск минимального элемента
           [obj, minval] = obj.getMinval();
                       
           for i = 1:size(obj.matrix, 1)
                for j = 1:size(obj.matrix, 2)
                    if ~ismember(j, obj.cols)
                        obj.matrix(i, j) = obj.matrix(i, j) - minval;
                    end
                    
                    if ismember(i, obj.rows)
                         obj.matrix(i, j) = obj.matrix(i, j) + minval;
                    end
                end
           end
           
           
        end
        
        %поиск минимума в неотмеченных
        %работает корректно 
        function [obj, minval] = getMinval(obj)
            minval = max(max(obj.matrix));
            
            for i = 1:size(obj.matrix,1)
                for j = 1:size(obj.matrix,2)
                     if (obj.matrix(i,j) < minval ...
                             && ~ismember(i,obj.rows) ...
                             && ~ismember(j, obj.cols))                    
                        minval = obj.matrix(i,j);
                    end
                end
            end         
        end
        
        %поиск второго нуля в неотмеченных
        %работает корректно (вроде бы)
        function [obj,flag,  dcol] = doubleZero(obj, row)
            flag = false;
            dcol = -1;
            
            for i = 1:size(obj.marked, 1)
                if obj.marked(i) == row
                    flag = true;
                    tmp = obj.marked(i,:);
                    dcol = tmp(2);
                    return;
                end                
            end
        end
        
        function obj = Lchain(obj)
            obj.lpath = [];
            
            cpoint = obj.smarked(size(obj.smarked, 1), :);
            obj.lpath = [obj.lpath; cpoint];
            
            state = false; %смотрим строчки (false) или колонки
            cstate = true;
            
            while cstate
                if state == false
                    for i = 1:size(obj.marked,1)
                        point = obj.marked(i, :);
                        if cpoint(2) == point(2)
                            obj.lpath = [obj.lpath; point];
                            cpoint = point;
                            state = ~state;
                        end
                    end
                    
                    if state == false  
                        cstate = false;
                    end
                else
                    for i = 1:size(obj.smarked,1)
                        point = obj.smarked(i, :);
                        if cpoint(1) == point(1)
                            obj.lpath = [obj.lpath; point];
                            cpoint = point;
                            state = false;
                        end
                    end                   
                end              
            end
    
        end
        
        
        function obj = printMatrix(obj)
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                   fprintf("%d  ", obj.matrix(i, j));
                end
                fprintf("\n");
            end
        end
        
        function obj = printIteration (obj)
            %отмечаем плюсиками колонки
            for i = 1:size(obj.matrix,2)
                if ismember(i, obj.cols)
                    fprintf("+  ");
                else
                    fprintf("   ");            
                end
            end
            fprintf("\n");
            
            
            for i = 1:size(obj.matrix,1)
                for j = 1:size(obj.matrix,2)
                    %элемент со штрихом?
                    if (size(obj.smarked, 2) > 0 && ...
                            ismember([i,j], obj.smarked, 'rows'))
                         fprintf("%d' ", obj.matrix(i,j))
                    else
                    %элемент со звездочкой?
                      if  ismember([i,j], obj.marked, 'rows')
                          fprintf("%d* ", obj.matrix(i,j))
                      else
                    %просто элемент
                          fprintf("%d  ", obj.matrix(i,j))
                      end
                    end
                    
                end
                
                %отмечаем плюсиками строчки
                if ismember(i,obj.rows)
                    fprintf('+')
                end
                fprintf('\n');
                
            end
            
            
            
        end
        
        function obj = Count(obj)
            %проверка типа задачи
            obj = obj.start;
            %создание изначальных нулей
            obj = obj.preprocessing;
            %создание системы независимых нулей
            obj = obj.coverage;
            
            %если вдруг не получилось с первого раза
            if not(obj.count == length(obj.matrix))
                obj = obj.alternate_coverage();
            end
            
            opt = 0;
            
            fprintf("\n");
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                    if ismember([i,j],obj.marked, 'rows')
                         fprintf("%d  ", 1)
                         opt = opt + obj.cost(i,j);
                    else
                         fprintf("%d  ", 0)
                    end
                end
                fprintf("\n");
            end
            fprintf("Решение f_opt = %d \n", opt);
            
        end
    end
end
