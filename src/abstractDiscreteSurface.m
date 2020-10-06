classdef abstractDiscreteSurface < simplicial2Complex
% abstractDiscreteSurface 
%   (extends simplicial2Complex)
%
% Generalized the 2-simplex checking for the surface
% boundry which will be needed later.
%

    methods
        
        function obj = abstractDiscreteSurface(v,e,f) 
        % COSTRUTTORE
        % abstractDiscreteSurface creates a discrete surface
        % v has to be an non-negative integer (number of vertices)
        % e has to be a matrix with 2 rows (each column has to describe an edge)
        % f has to be a matrix with 3 rows (each column has to describe a face)
            obj@simplicial2Complex(v,e,f);
            if ~obj.isSurface()
                error('Error. Input is not a discrete surface.');
            end               
        end 
               
        function tf = hasBoundary(obj)
        % Returns true if the surface has boundary, false otherwise
        
            % since we know that it is a surface we just need 
            % to check if the edge is contained in only one face
            % we will use the B1 matrix to do that.
            
            tf = ismember(1, full(sum(secondAdiacencyMatrix(obj), 2)));
        end
        
        function euler = eulerCharacteristic(obj)
        % Returns the Euler characteristic of the surface
            euler = obj.numberOfVertices() - obj.numberOfEdges() + obj.numberOfFaces();   
        end
        
         function disp(obj)
         % Displays the object
            fprintf('Abstract discrete surface: %d vertices, %d edges, %d faces.\n\n',obj.nVertices,obj.nEdges,obj.nFaces);
         end
    end
    
end

