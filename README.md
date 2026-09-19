# Compiler Final Project
`of NCU course 【CE3006*】編譯器 Compiler`
`from 112502507 資工3A 陳芊羽`
`last edited at 2025/12/18`

一個 Mini-LISP interpreter 的簡單實作
Mini-LISP 的詳細資訊請參見 [MiniLisp.pdf](https://drive.google.com/drive/u/3/folders/1zRgZ14Zl38pWWXxCI0XeoRIy8dZl68lR)
此程式支援以下功能
![image](https://images.plurk.com/6MVbNP3VSnqKWR6oIDuzzv.png)

## files 
- demo使用的版本：
    - lex: Final_Project.l
    - yacc: Final_Project_samename.y
    - 執行檔: Final_Project

- other_version：
  備用版本，在 demo 時理論上並未使用，僅作為備用附上。
  - version 86p:
    Final_Project_86.l + Final_Project_86.y → Final_Project_86
    僅實作前 86 分，無 AST
  - version AST_basic:
    Final_Project.l + Final_Project.y → Final_Project
    與正式版大同小異，但未有正式版的 子 func_call 繼承父 func_call's param

## requirements
- 實作語言：lex/yacc
  安裝方式請參見課程ppt：LexYaccForWindows
  - MinGWInstaller
- 建議環境：課程提供的 CompilerVM
  安裝方式請參見課程ppt：Lex&yacc環境教學
  - VirtualBox
  - [CompilerVM.ova](https://drive.google.com/file/d/1B5-8J7H74mcXoZrO9bXkzbaWVDh_togP/view)

## how to run
在檔案所在目錄底下開啟 cmd，輸入對應指令

- 執行：
  ./Final_Project_samename < 欲編譯的 lsp 的路徑
  
- 編譯：
  bison -d -o Final_Project_samename.tab.c Final_Project_samename.y
  gcc -c -g -I.. Final_Project_samename.tab.c

  flex -o Final_Project.yy.c Final_Project.l
  gcc -c -g -I.. Final_Project.yy.c

  gcc -o Final_Project_samename Final_Project_samename.tab.o Final_Project.yy.o -ll
