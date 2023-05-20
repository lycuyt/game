.MODEL LARGE

.STACK 0100H

.DATA
    ;khoi tao bien,hang
    EXIT DB 0;khoi tao EXIT=0
    PLAYER_POS DW 1760D;vi tri nguoi choi       
    
    ARROW_POS DW 0D;vi tri mui ten              
    ARROW_STATUS DB 0D;trang thai ban dau cua mui ten
    ARROW_LIMIT DW  22D;gioi han toi da cua mui ten
    
    LOON_POS DW 3860D ;vi tri ban dau cua bong
    LOON_STATUS DB 0D ;trang thai ban dau cua bong
             
                                                ;huong cua nguoi choi
                                                ;UP=8, DOWN=2
    DIRECTION DB 0D;huong di nguoi choi
    
    STATE_BUF DB '00:0:0:0:0:0:00:00$';trang thai diem cua nguoi choi          
    HIT_NUM DB 0D; so lan ban trung
    HITS DW 0D;luu tru diem nguoi choi
    MISS DW 0D;so lan nguoi choi ban ko trung  
    
    GAME_OVER_STR DW '  ',0AH,0DH ;chuoi xuat hien khi game ket thuc
    DW '                             |               |',0AH,0DH
    DW '                             |---------------|',0AH,0DH
    DW '                             | ^   SCORE   ^ |',0AH,0DH
    DW '                             |_______________|',0AH,0DH
    DW ' ',0AH,0DH 
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW '                                GAME OVER',0AH,0DH
    DW '                        PRESS ENTER TO START AGAIN$',0AH,0DH 
    
 
    GAME_START_STR DW '  ',0AH,0DH ;chuoi xuat hien khi game bat dau
    
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW '                ====================================================',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH                                        
    DW '               ||       *    BALLOON SHOOTING GAME      *          ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||--------------------------------------------------||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH          
    DW '               ||     USE UP AND DOWN KEY TO MOVE PLAYER           ||',0AH,0DH
    DW '               ||          AND SPACE BUTTON TO SHOOT               ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||            PRESS ENTER TO START                  ||',0AH,0DH 
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '                ====================================================',0AH,0DH
    DW '$',0AH,0DH




.CODE
    MAIN PROC
        MOV AX,@DATA
        MOV DS,AX;khoi tao ds
        
        
        MOV AX, 0B800H  ;lay dia chi cua bo nho video (video memory) cua màn hinh ve gan vào thanh ghi AX
        MOV ES,AX ;dat dia chi cua vung bo nho video, cu the là vung bo nho man hinh VGA, vào thanh ghi ES.
        
        JMP GAME_MENU;nhay den GAME_MENU de hien thi menu chinh                              
                                                                           
        MAIN_LOOP:                                 
                                                   
            MOV AH,1H;kiem tra phim nao duoc nhan
            INT 16H                                
            JNZ KEY_PRESSED ;nhay den KEY_PRESSED de xu li phim
            JMP INSIDE_LOOP ;khong thi tiep tuc vong lap                        
            
            INSIDE_LOOP:                           
                
                CMP MISS,9;neu miss>=9 nhay den GAME_OVER
                JGE GAME_OVER
                
                MOV DX,ARROW_POS;Neu vi tri mui ten trung voi vi tri bong ->HIT
                CMP DX, LOON_POS
                JE HIT
                
                CMP DIRECTION,8D;so sanh 
                JE PLAYER_UP ;bang thi di len
                CMP DIRECTION,2D;so sanh
                JE PLAYER_DOWN;khong bang thi di xuong
                
                MOV DX,ARROW_LIMIT
                CMP ARROW_POS, DX;neu vi tri arrow hien tai>=gioi han toi da cua mui ten thi ->HIDE_ARROW de an bong di
                JGE HIDE_ARROW
                
                CMP LOON_POS, 0D;kiem tra bong bi mat
                JLE MISS_LOON ; bong ra khoi tam ngam cua nguoi choi->miss
                JNE RENDER_LOON ; ve bong moi
            
                HIT:                               
                    MOV AH,2  ;phat ra tieng neu trung
                    MOV DX, 7D
                    INT 21H 
                    
                    INC HITS;tang hit de cap nhat diem                       
                    
                    LEA BX,STATE_BUF;dat dia chi cua chuoi STATE_BUF vào thanh ghi BX.              
                    CALL SHOW_SCORE ;goi hàm SHOW_SCORE de tinh toan và hien thi diem so cua tro choi 
                    LEA DX,STATE_BUF
                    MOV AH,09H
                    INT 21H ; chuoi STATE_BUF  duoc hien thi tren man hinh.
                    
                    MOV AH,2 ;in ra mot ky tu xuong dong
                    MOV DL, 0DH
                    INT 21H    
                    
                    JMP FIRE_LOON;hien thi bong moi
            
                RENDER_LOON:;ve bong
                    MOV CL, ' ' ;an bong cu
                    MOV CH, 1111B;mau cua bong
                                                   
                    MOV BX,LOON_POS;dat dia chi cua bien LOON_POS vào thanh ghi BX.                
                    MOV ES:[BX], CX;cap nhat vi tri và màu sac cue bong bang cach gan gia tri thanh ghi cx vao dia chi vung nho con tro tuong ung
                        
                    SUB LOON_POS,160D;di chuyen vi tri bong len man hinh
                    MOV CL, 15D ;di chuyen bong len tren man hinh
                    MOV CH, 1101B ;dai dien mau nen cua bong
                                                                
                    MOV BX,LOON_POS;dat dia chi cua bien LOON_POS vào thanh ghi BX. 
                    MOV ES:[BX], CX;cap nhat vi tri và màu sac cua bong
                    
                    CMP ARROW_STATUS,1D;kiem tra mui ten da duoc hien thi chua
                    JE RENDER_ARROW ;bang thi ve 
                    JNE INSIDE_LOOP2 ;khong thi lap chowf dowi nguoi bawn lan nua
                
                RENDER_ARROW:;hien thi arrow
                
                    MOV CL, ' ';an mui ten cu                    
                    MOV CH, 1111B;mau arrow
                
                    MOV BX,ARROW_POS;chuyen dia chi cua bien ARROW_POS vào thanh ghi BX. 
                    MOV ES:[BX], CX;cap nhat vi tri và màu sac cue arrow bang cach gan gia tri thanh ghi cx vao dia chi vung nho con tro tuong ung
                        
                    ADD ARROW_POS,4D;cap nhat vi tri moi cua arrow
                    MOV CL, 26D ;di chuyen sang phai
                    MOV CH, 1001B;mau nen arrow
                
                    MOV BX,ARROW_POS;di chuyen con tro den vi tri mui ten moi
                    MOV ES:[BX], CX ;cap nhat vi tri và màu sac cua arrow
                
                INSIDE_LOOP2:
                    
                    MOV CL, 125D;di chuyen vi tri cua nguoi choi sang phai 
                    MOV CH, 1100B ; Cài dat màu nen cho nguoi choi là màu xanh duong.
                    
                    MOV BX,PLAYER_POS;chuyen con tro den vi tri nguoi choi
                    MOV ES:[BX], CX ;ve nguoi choi moi o vi tri moi
                               
                    CMP EXIT,0
                    JE MAIN_LOOP;neu EXIT=0 quay lai vong lap chinh                  
                    JMP EXIT_GAME;Exit khac 0 thi thoat game
         
                    JMP INSIDE_LOOP2;nhay den INSIDE_LOOP2 neu game chua ket thuc
        
           
        PLAYER_UP:;di chuyen nguoi choi len tren man hinh                               
            MOV CL, ' ';an nguoi choi cu
            MOV CH, 1111B;mau nguoi choi(trang)
                
            MOV BX,PLAYER_POS;chuyen dia chi cua bien PLAYER_POS vào thanh ghi BX.                    
            MOV ES:[BX], CX;cap nhat vi tri và màu sac cua nguoi choi bang cach gan gia tri thanh ghi cx vao dia chi vung nho con tro tuong ung
            
            SUB PLAYER_POS, 160D;thiet lap vi tri moi
            MOV DIRECTION, 0;huong di chuyen nguoi choi:dung yen    
        
            JMP INSIDE_LOOP2;ve nguoi choi moi trong vong lap
            
        PLAYER_DOWN:
            MOV CL, ' ';an nguoi choi cu                           
            MOV CH, 1111B;mau nguoi choi                         
                                                  
            MOV BX,PLAYER_POS;chuyen dia chi cua bien PLAYER_POS vào thanh ghi BX.                      
            MOV ES:[BX], CX;cap nhat vi tri và màu sac cua nguoi choi bang cach gan gia tri thanh ghi cx vao dia chi vung nho con tro tuong ung
            
            ADD PLAYER_POS,160D;thiet lap vi tri moi
            MOV DIRECTION, 0;thiet lap lai huong di
            
            JMP INSIDE_LOOP2;ve nguoi choi moi trong vong lap
        
        KEY_PRESSED:;phan xu li dau vao                              
            MOV AH,0
            INT 16H;doc input tu ban phim
        
            CMP AH,48H                          
            JE UPKEY;nhay den upkey neu phim up duoc nhan
            CMP AH, 50H
            JE DOWNKEY;nhay den downkey neu phim down duoc nhan
            
            CMP AH,39H                            
            JE SPACEKEY;nhay den spacekey neu phim space duoc nhan
            
            CMP AH,4BH                            
            JE LEFTKEY;nhay den leftkey neu phim left duoc nhan(dung de sua loi)
             
                                                  
            JMP INSIDE_LOOP;neu khong co phim nao duoc nhan ,chuong trinh tiep tuc lap 
        
        LEFTKEY:                                  
            
            INC MISS ;tang miss
                    
            LEA BX,STATE_BUF
            CALL SHOW_SCORE;cap nhat hien thi diem 
            LEA DX,STATE_BUF
            MOV AH,09H
            INT 21H  ;in ra state_buf
            
            MOV AH,2
            MOV DL, 0DH;di chuyen ve dau dong
            INT 21H
            JMP INSIDE_LOOP;nhay den inside_loop
            
        UPKEY:                                    
            MOV DIRECTION, 8D;cap nhat huong di nguoi choi: di len
            JMP INSIDE_LOOP;nhay den inside_loop
        
        DOWNKEY:
            MOV DIRECTION, 2D ;cap nhat huong di:di xuong                   
            JMP INSIDE_LOOP;nhay den inside_loop
            
        SPACEKEY:;ban mot mui ten                                
            CMP ARROW_STATUS,0
            JE  FIRE_ARROW ;neu trang thai arrow=0 ban 
            JMP INSIDE_LOOP;ko thi nhay den inside_loop
        
        FIRE_ARROW:                              
            MOV DX, PLAYER_POS;di chuyen mui ten den vi tri nguoi choi                   
            MOV ARROW_POS, DX;ban mui ten tu vi tri nguoi choi
            
            MOV DX,PLAYER_POS                     
            MOV ARROW_LIMIT, DX;chuyen vi tri nguoi choi vao arrow_limit                   
            ADD ARROW_LIMIT, 22D  ;dat gioi han cua mui ten
            
            MOV ARROW_STATUS, 1D ;dat trang thai arrow=1 tranh viec ban nhieu mui ten 1 luc                 
            JMP INSIDE_LOOP ;nhay den vong lap tiep tuc choi                      
        
        MISS_LOON:
            ADD MISS,1 ;cap nhat miss                           
        
            LEA BX,STATE_BUF                     
            CALL SHOW_SCORE ;cap nhat hien thi diem 
            LEA DX,STATE_BUF
            MOV AH,09H
            INT 21H  ;in state_buf
                                                  
            MOV AH,2
            MOV DL, 0DH ;di chuyen ve dau dong
            INT 21H
        JMP FIRE_LOON;nhay den fire_loon
            
        FIRE_LOON:;xu li khi ban mot qua bong moi                                
            MOV LOON_STATUS, 1D;dat trang thai-> hien thi
            MOV LOON_POS, 3860D;dat lai vi tri   
            JMP RENDER_LOON ;ve qua bong moi ra man hinh
            
        HIDE_ARROW:;an arrow
            MOV ARROW_STATUS, 0;dat lai trang thai:aanr                
            
            MOV CL, ' '   ;an mui ten
            MOV CH, 1111B;mau mui ten(mau trong)
            
            MOV BX,ARROW_POS 
            MOV ES:[BX], CX;ve mui ten moi o vi tri moi
            
            CMP LOON_POS, 0D 
            JLE MISS_LOON;neu vi tri <=0D->miss_loon
            JNE RENDER_LOON;neu van con thi hien thi ra 
            
            JMP INSIDE_LOOP2;nhay den inside_loop2
                                                  
        GAME_OVER:;in ra man hinh khi kt game
            MOV AH,09H
            ;MOV DH,0
            MOV DX, OFFSET GAME_OVER_STR
            INT 21H;in chuoi ket thuc tro choi
            
            
            ;an ten lua bang cach dat gia tri ki tu và gia tri thuoc tinh cua no thành khoang trang
            MOV CL, ' '                           
            MOV CH, 1111B 
            MOV BX,ARROW_POS;di chuyen con tro den vi tri mui ten                      
            ;an nguoi choi
            MOV CL, ' '                           
            MOV CH, 1111B 
            MOV BX,PLAYER_POS  
         
            
            ;reset gia tri de bat dau choi lan nua                         
            MOV MISS, 0D;so lan khong trung
            MOV HITS,0D; so lan ban trung
            
            MOV PLAYER_POS, 1760D;vi tri nguoi choi(dat giua cot ben trai)
        
            MOV ARROW_POS, 0D;vi tri mui ten:an mui ten o dau trang
            MOV ARROW_STATUS, 0D;trang thai mui ten:an 
            MOV ARROW_LIMIT, 22D;gioi han mui ten      
        
            MOV LOON_POS, 3860D;vi tri bong(duoi trang)       
            MOV LOON_STATUS, 0D;trang thai bong:an
                 
            MOV DIRECTION, 0D;huong di chuyen nguoi choi(khong di chuyen)
                                                   ;WAIT FOR INPUT
            INPUT:
                MOV AH,1;thiet lap che do doc tu ban phim
                INT 21H;doc mot ky tu tu ban phim ->dua no vao al
                CMP AL,13D
                JNE INPUT;neu khong an phim enter quay lai input
                CALL CLEAR_SCREEN;neu an enter thi goi clear_screen de xoa man hinh va chuan bi tro choi moi
        JMP MAIN_LOOP;bat dau vong lap tro choi
            
        
        GAME_MENU:;tao man hinh game menu
                                                  
            MOV AH,09H
            MOV DH,0
            MOV DX, OFFSET GAME_START_STR
            INT 21H ;in chuoi game_start_str
                                                  
            INPUT2:;cho nguoi choi nhap du lieu tu ban phim
                MOV AH,1
                INT 21H
                CMP AL,13D
                JNE INPUT2;neu khong nhap enter thi quay lai input2
                CALL CLEAR_SCREEN;neu an enter thi goi clear_screen xoa man hinh truoc khi bat dau choi
                 ;hien thi diem
                LEA BX,STATE_BUF                   
                CALL SHOW_SCORE;cap nhat hien thi diem 
                LEA DX,STATE_BUF
                MOV AH,09H
                INT 21H;in ra man hinh state_buf
            
                MOV AH,2
                MOV DL, 0DH
                INT 21H;in ki tu xuong dong
                
                JMP MAIN_LOOP;nhay den main_loop bat dau tro choi
        
       EXIT_GAME:;ket thuc game                                 
            MOV EXIT,10D ;dat exit=10 de bao hieu ket thuc
    
    MAIN ENDP

    SHOW_SCORE PROC
        LEA BX,STATE_BUF;load dia chi chuoi ket qua vao thanh ghi bx
        
        MOV DX, HITS;lay gia tri so lan ban trung luu vao thanh gi dx
        ADD DX,48D ;chuyen gia tri so thanh gia tri ASCII(dang ki tu) tuong ung
        ;hien thi chuoi hits:gia tri so lan ban trung
        MOV [BX], 9D
        MOV [BX+1], 9D
        MOV [BX+2], 9D
        MOV [BX+3], 9D
        MOV [BX+4], 'H'
        MOV [BX+5], 'I'                                        
        MOV [BX+6], 'T'
        MOV [BX+7], 'S'
        MOV [BX+8], ':'
        MOV [BX+9], DX
        ;hien thi chuoi miss:gia tri so lan ban truot
        MOV DX, MISS
        ADD DX,48D
        MOV [BX+10], ' '
        MOV [BX+11], 'M'
        MOV [BX+12], 'I'
        MOV [BX+13], 'S'
        MOV [BX+14], 'S'
        MOV [BX+15], ':'
        MOV [BX+16], DX
      RET;quay ve ham goi    
    SHOW_SCORE ENDP 

    CLEAR_SCREEN PROC NEAR
        MOV AH,0;chua bi ma ham cho lenh goi ngat video        
        MOV AL,3;xoa man hinh
        INT 10H;ngat video         
      RET;quay ve ham goi
    CLEAR_SCREEN ENDP

END MAIN