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
        %для отметок * 
        marked 
        %для отметок '
        smarked
        %задача максимизации
        flag 
        %счетчик СНН
        count 
    end
    
    methods
         %конструктор класса
         function obj = HungarianMethod(m, maxFlag)
            obj.matrix = m;
            obj.marked = [];
            obj.smarked = [];
            obj.count = 0;
           
            obj.lpath = [];   
            obj.flag = maxFlag;
         end
         
         %проверка задачи и изменение матрицы
         function obj = start(obj)
             if obj.flag 
                 m_max = max(max(obj.matrix));
                 new_matrix = m_max - obj.matrix;
                 obj.matrix = new_matrix;
             end
         end
         
        %предобработка матрицы (вычитание наименьших элементов)
        function obj = preprocessing(obj)
            %вычесть минимум из каждой строки
            for i = 1:length(obj.matrix)
                obj.matrix(i, :) = obj.matrix(i, :) - min(obj.matrix(i, :));
            end
            
            obj.matrix = obj.matrix';
            %вычесть минимум из каждого столбца
            for i = 1:length(obj.matrix)
                obj.matrix(i, :) = obj.matrix(i, :) - min(obj.matrix(i, :));
            end
            obj.matrix = obj.matrix';
                     
        end
        
        %создание системы независимых нулей
        function obj = coverage(obj)
            %проход по матрице
            
            %чтобы избежать выхода за пределы массива
            obj.marked = [obj.marked; [-1, -1]];
            
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                    if obj.matrix(i, j) == 0 
                        if not(ismember(i, obj.marked(:, 1)))
                            obj.marked = [obj.marked; [i, j]];
                            break;
                        end
                    end
                end
            end
            
            %удаление фиктивного элемента
            obj.marked(1, :) = [];
            obj.count = size(obj.marked);
        end
        
        %поиск первого неотмеченного нуля
        function [obj, flag, zi, zj] = isNull(obj)
            flag = false;
            zi = -1; 
            zj = -1;
            % поиск всех нулей
            [ii, jj] = find(~obj.matrix);
            %поиск первого нуля не в помеченных
            for i = 1:length(ii)
                if ~ismember(ii(i), obj.cols) && ~ismember(jj(i), obj.rows)
                    zi = ii(i);
                    zj = jj(i);
                    flag = true;
                    return;
                end
            end
            
        end
        
        %создание альтернативной системы независимых нулей
        function obj = alternate_coverage(obj)
               
            while obj.count ~= length(obj.matrix)
                %заполнение отметок
                obj.cols = obj.marked(:,2);
                if size(obj.rows(:, 1)) == 0
                    obj.rows = [];
                else 
                    obj.rows = obj.smarked(:,1);
                end
                
                %обнуляем новые отметки
                obj.smarked = [];
                
                %есть ли неотмеченные нули
                flags, zi, zj = obj.isNull();
                
                while true 
                    %если есть неотмеченный ноль
                    if flags
                        obj.smarked = [obj.smarked; [zi, zj]];
                        %есть ли второй ноль в строчке?
                        f, dr, dc = obj.doubleZero(zi);
                        
                        %если да, переопределяем
                        if f 
                            obj.rows = [obj.rows; zi ];
                            obj.cols(obj.cols == dc) = [];
                        else
                            %если нет, строим L-цепочку
                            obj.Lchain();
                            
                            for i = 1:size(obj.matrix,1)
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
                            
                            break;
                        end
                        flags, zi, zj = obj.isNull();
                    else 
                    %если нет неотмеченных нулей
                    obj = obj.makeNulls();
                    
                    flags, zi, zj = obj.isNull();
                    end
                    
                   
                end
                
            end
        end
        
        
        %если нет нулей в неотмеченных элементах, то нужно создать
        function obj = makeNulls(obj)          
            %поиск минимального элемента
            minval = obj.getMinval();
                       
           for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
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
        function [obj, minval] = getMinval(obj)
            minval = max(max(obj.matrix));
            
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                     if (obj.matrix(i,j) < minval ...
                             && ~ismember(i,obj.rows) ...
                             && ~ismember(j, obj.cols))                    
                        minval = cost(i,j);
                    end
                end
            end         
        end
        
        %поиск второго нуля в неотмеченных
        function [obj,flag, drow, dcol] = doubleZero(obj, row)
            flag = false;
            drow = -1;
            dcol = -1;
            
            for i = 1:size(obj.marked, 1)
                if obj.marked(i) == row
                    flag = true;
                    tmp = obj.marked(i,:);
                    drow = tmp(1);
                    dcol = tmp(2);
                    return;
                end                
            end
        end
        
        function obj = Lchain(obj)
            obj.lpath = [];
            
            cpoint = obj.smarked(size(obj.smarked, 1), :);
            obj.lpath = [obj.lpath; cpoint];
            
            state = false;
            cstate = true;
            
            while cstate
                if ~state
                    for i = 1:size(obj.marked,1)
                        point = obj.marked(i, :);
                        if cpoint == point
                            obj.lpath = [obj.lpath, point];
                            cpoint = point;
                            state = ~state;
                        end
                    end
                    
                    if ~state 
                        cstate = ~cstate;
                    end
                else
                    for i = 1:size(obj.smarked,1)
                        point = obj.smarked(i, :);
                        if cpoint == point
                            obj.lpath = [obj.lpath, point];
                            cpoint = point;
                            state = ~state;
                        end
                    end                   
                end              
            end
    
        end
        
        
        function obj = Do(obj)
            %проверка типа задачи
            obj = obj.start;
            %создание изначальных нулей
            obj = obj.preprocessing;
            %создание системы независимых нулей
            obj = obj.coverage;
            
            %если вдруг не получилось с первого раза
            if obj.count ~= length(obj.matrix)
                obj = obj.alternate_coverage();
            end
            
            for i = 1:length(obj.matrix)
                for j = 1:length(obj.matrix)
                    if ismember([i,j],obj.marked, 'rows')
                         fprintf("%d  ", 1)
                    else
                         fprintf("%d  ", 0)
                    end
                end
                fprintf("\n");
            end
            
        end
    end
end
