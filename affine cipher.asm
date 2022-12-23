;affine cipher
;key a= 5 b= 7                 
DATA SEGMENT
    
    MSG1   DB  0DH , 0AH , 0DH , 0AH , "ENTER THE PLAIN TEXT TO BE ENCRYPTED : $"  
    MSG2   DB  0DH , 0AH , 0DH , 0AH , "CIPHER TEXT (ENCRYPTED TEXT) : $"          
    
    MSG3   DB  0DH , 0AH , 0DH , 0AH , "DO YOU WANT TO ENCRYPT OR DECRYPT ?" , 0DH , 0AH , 0DH , 0AH , "   ENTER 'E' FOR ENCRYPT OR 'D' FOR DECRYPT : $"    
    
    MSG4   DB  0DH , 0AH , 0DH , 0AH , "ENTER THE CIPHER TEXT TO BE DECRYPTED : $" 
    MSG5   DB  0DH , 0AH , 0DH , 0AH , "PLAIN TEXT (DECRYPTED TEXT) : $"           
    
    MSG6   DB  0DH , 0AH , 0DH , 0AH , "                AFFINE CIPHER $"
    
    MSG7   DB  0DH , 0AH , 0DH , 0AH , "NOTE  : ENTER ONLY LOWER CASE CHARACTERS $"   
    
    MSG8   DB  0DH , 0AH , 0DH , 0AH , "DO YOU WANT TO CONTINUE?" , 0DH , 0AH , 0DH , 0AH , "   ENTER 'Y' FOR YES OR 'N' FOR NO : $"
    
    MSG9   DB  0DH , 0AH , 0DH , 0AH , "       NO SPACE IN BETWEEN WORDS AND NO SPECIAL CHARACTERS $"        
    
    BUFF   DB  103
           DB  ?  
    
    PLAIN  DB  100  DUP(?) ; ARRAY TO STORE PLAIN TEXT
    
    BUFDECR   DB  103
              DB  ?  
    
    CIPHER DB  100  DUP(?) ; ARRAY TO STORE CIPHER TEXT
    
    A      DB  05H        
    B      DW  0007H       
    B1     DB  07H         
    C      DB  ?
    X      DB  ?           
    
    


CODE SEGMENT
    
    start:
    ASSUME CS : CODE , DS : DATA
    
     
    
        MOV AX , DATA
        MOV DS , AX
        
        CIPHER_CONTINUE:
        
            MOV AH , 09H
            LEA DX , MSG6    
            INT 21H
        
            MOV AH , 09H
            LEA DX , MSG3    
            INT 21H
        
            MOV AH , 01H     ; INPUT CHARACTER 'E' OR 'D' IN AL
            INT 21H
        
            CMP AL , 'E'
            JNE DECRYPTION 
        
            ;ENCRYPTION
            
                MOV AH , 09H
                LEA DX , MSG7     
                INT 21H
                
                MOV AH , 09H
                LEA DX , MSG9     
                INT 21H
                        
                MOV AH , 09H        
                LEA DX , MSG1     
                INT 21H
                                  
                LEA DX , BUFF
                MOV AH , 0AH      ; INPUT PLAIN TEXT FROM USER
                INT 21H
        
                MOV CL , BUFF+1   ; CL CONTAINS THE NUMBER OF CHARACTERS IN THE INPUT STRING
                
                LEA SI , PLAIN   
                LEA BX , CIPHER
                MOV CH , 26       ; ENGLISH ALPHABET CONTAINS 26 LETTERS
        
                ;TEXT ENCRYPTION   
                    
                REPEAT:     ;equation c =(ax+b) mod26
                
                    MOV AL , [SI]
                    SUB AL , 'a'
                    MUL A
                    ADD AX , B
                    DIV CH
                    ADD AH , 'a'
            
                    MOV [BX] , AH
                             
                    INC SI
                    INC BX
                    DEC CL
                    CMP CL , 00H
                    JNE REPEAT 
                         
                MOV AH , 09H             
                LEA DX , MSG2      
                INT 21H
        
                MOV CL , BUFF+1    ; CL CONTAINS NUMBER OF CHARACTERS IN THE CIPHER TEXT
                LEA BX , CIPHER
                
                ;DISPLAY CIPHER TEXT (ENCRYPTED TEXT)
                    
                PRINT: 
                    
                    MOV AH , 02H
                    MOV DL , [BX]
                    INT 21H
            
                    INC BX
                    DEC CL
                    CMP CL , 0000H
                    JNE PRINT
                
                JMP WANT_TO_REPEAT 
;---------------------------------------------------------------------------------
        
            ;DECRYPTION
            
            DECRYPTION:
                
                MOV AH , 09H
                LEA DX , MSG7      
                INT 21H
                
                MOV AH , 09H
                LEA DX , MSG9      
                INT 21H
                
                MOV AH , 09H
                LEA DX , MSG4      
                INT 21H
            
                LEA DX , BUFDECR
                MOV AH , 0AH       ; INPUT CIPHER TEXT FROM USER
                INT 21H
                
                MOV CL , BUFDECR[1]     ; CL CONTAINS NUMBER OF CHARCACTERS IN CIPHER TEXT
                                       
                MOV CH , 26             
                
                MOV BL , 00H
                
                FIND_INVERSE:           ; CALCULATE INVERSE OF A
                
                    INC BL
                    MOV AL , BL
                    MUL A
                    DIV CH
                    
                    CMP AH , 01H    
                    
                    JNE FIND_INVERSE 
                    
                MOV X , BL              ; STORE INVERSE OF A IN X 
                LEA SI , CIPHER
                LEA BX , PLAIN
                  
                ;AFFINE CIPHER
                ;TEXT DECRYPTION
                
                DEC_REP:
                    
                    MOV AH , 00H
                    MOV AL , [SI]
                    SUB AL , 'a'
                    SUB AL , B1
                    IMUL X
                    IDIV CH
                    ADD AH , CH
                    MOV AL , AH
                    MOV AH , 00H
                    DIV CH
                    ADD AH , 'a'
                    
                    MOV [BX] , AH
                    
                    INC SI
                    INC BX
                    DEC CL
                    CMP CL , 00H
                    JNE DEC_REP
                    
                MOV AH , 09H             
                LEA DX , MSG5        
                INT 21H
                
                MOV CL , BUFDECR+1   ; CL CONTAINS NUMBER OF CHARACTERS IN THE PLAIN TEXT
                LEA BX , PLAIN
                    
                ;DISPLAY PLAIN TEXT (DECRYPTED TEXT)
                
                PLAIN_PRINT: 
                
                    MOV AH , 02H
                    MOV DL , [BX]
                    INT 21H
                    
                    INC BX
                    DEC CL
                    CMP CL , 00H
                    JNE PLAIN_PRINT
                    
            WANT_TO_REPEAT:
                
                MOV AH , 09H             
                LEA DX , MSG8   
                INT 21H
        
                MOV AH , 01H     ; INPUT CHARACTER 'Y' OR 'N' IN AL
                INT 21H
                
                CMP AL , 'N'
                JNE CIPHER_CONTINUE 
        
        ;TERMINATE PROGRAM
                  
        MOV AH , 4CH   
        INT 21H
        
    
 end start
 start:
 ;entry point
 end start 
    
    END START
