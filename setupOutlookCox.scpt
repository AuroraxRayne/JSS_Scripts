FasdUAS 1.101.10   ��   ��    k             l     ��  ��    , & DEFINE VARIABLES & READ IN PARAMETERS     � 	 	 L   D E F I N E   V A R I A B L E S   &   R E A D   I N   P A R A M E T E R S   
  
 l     ��������  ��  ��        j     �� ��  0 exchangeserver ExchangeServer  m        �   � h t t p s : / / a u t o d i s c o v e r - s . o u t l o o k . c o m / a u t o d i s c o v e r / a u t o d i s c o v e r . s v c / W S S e c u r i t y      l     ��������  ��  ��        j    �� �� 0 emaildomain emailDomain  m       �    c o x a u t o i n c . c o m      l     ��������  ��  ��        j    �� �� 0 windowsdomain WindowsDomain  m       �    C o x   A u t o   I n c       l     ��������  ��  ��      ! " ! l     ��������  ��  ��   "  # $ # l     �� % &��   % ? 9############# Do Not Edit Below This Line ##############     & � ' ' r # # # # # # # # # # # # #   D o   N o t   E d i t   B e l o w   T h i s   L i n e   # # # # # # # # # # # # # #   $  ( ) ( l     ��������  ��  ��   )  * + * l     �� , -��   , G AThe fullName and shortName properties are populated automatically    - � . . � T h e   f u l l N a m e   a n d   s h o r t N a m e   p r o p e r t i e s   a r e   p o p u l a t e d   a u t o m a t i c a l l y +  / 0 / j   	 �� 1�� 0 	shortname 	shortName 1 m   	 
 2 2 � 3 3   0  4 5 4 j    �� 6�� 	0 lname   6 m     7 7 � 8 8   5  9 : 9 j    �� ;�� 	0 fname   ; m     < < � = =   :  > ? > j    �� @�� 0 fullname FullName @ m     A A � B B   ?  C D C l     ��������  ��  ��   D  E F E l     �� G H��   G - 'Get the user's short name and full name    H � I I N G e t   t h e   u s e r ' s   s h o r t   n a m e   a n d   f u l l   n a m e F  J K J l     L���� L r      M N M I    �� O��
�� .sysoexecTEXT���     TEXT O l     P���� P m      Q Q � R R � / b i n / p s   - a j x   |   / u s r / b i n / g r e p   - m   1   ' F i n d e r . a p p '   |   / u s r / b i n / a w k   ' { p r i n t   $ 1 } '��  ��  ��   N o      ���� 0 	shortname 	shortName��  ��   K  S T S l    U���� U r     V W V I   �� X��
�� .sysoexecTEXT���     TEXT X l    Y���� Y b     Z [ Z b     \ ] \ m     ^ ^ � _ _ H / u s r / b i n / d s c l   / S e a r c h   - r e a d   " / U s e r s / ] o    ���� 0 	shortname 	shortName [ m     ` ` � a a � "   F i r s t N a m e   2 > / d e v / n u l l   |   g r e p   "   "   |   t a i l   - 1   |   s e d   ' s / ^   * / / '   |   s e d   ' s / F i r s t N a m e :   / / g '��  ��  ��   W o      ���� 	0 fname  ��  ��   T  b c b l    3 d���� d r     3 e f e I    -�� g��
�� .sysoexecTEXT���     TEXT g l    ) h���� h b     ) i j i b     ' k l k m     ! m m � n n H / u s r / b i n / d s c l   / S e a r c h   - r e a d   " / U s e r s / l o   ! &���� 0 	shortname 	shortName j m   ' ( o o � p p � "   L a s t N a m e   2 > / d e v / n u l l   |   g r e p   "   "   |   t a i l   - 1   |   s e d   ' s / ^   * / / '   |   s e d   ' s / L a s t N a m e :   / / g '��  ��  ��   f o      ���� 	0 lname  ��  ��   c  q r q l  4 G s���� s r   4 G t u t I  4 A�� v��
�� .sysoexecTEXT���     TEXT v l  4 = w���� w b   4 = x y x b   4 ; z { z m   4 5 | | � } } H / u s r / b i n / d s c l   / S e a r c h   - r e a d   " / U s e r s / { o   5 :���� 0 	shortname 	shortName y m   ; < ~ ~ �   � "   R e a l N a m e   2 > / d e v / n u l l   |   g r e p   "   "   |   t a i l   - 1   |   s e d   ' s / ^   * / / '   |   s e d   ' s / R e a l N a m e :   / / g '��  ��  ��   u o      ���� 0 fullname FullName��  ��   r  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � < 6Enable Access for Assisted Devices (for GUI scripting)    � � � � l E n a b l e   A c c e s s   f o r   A s s i s t e d   D e v i c e s   ( f o r   G U I   s c r i p t i n g ) �  � � � l  H O ����� � I  H O�� � �
�� .sysoexecTEXT���     TEXT � m   H I � � � � � n / u s r / b i n / t o u c h   / p r i v a t e / v a r / d b / . A c c e s s i b i l i t y A P I E n a b l e d � �� ���
�� 
badm � m   J K��
�� boovtrue��  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l  P U ����� � I   P U�������� $0 createnewaccount createNewAccount��  ��  ��  ��   �  � � � l     ��������  ��  ��   �  ��� � i     � � � I      �������� $0 createnewaccount createNewAccount��  ��   � k     � � �  � � � l     �� � ���   � E ?Determine the emailAddress based on the information we've found    � � � � ~ D e t e r m i n e   t h e   e m a i l A d d r e s s   b a s e d   o n   t h e   i n f o r m a t i o n   w e ' v e   f o u n d �  � � � r      � � � b      � � � b      � � � b      � � � b      � � � o     ���� 	0 fname   � m     � � � � �  . � o    ���� 	0 lname   � m     � � � � �  @ � o    ���� 0 emaildomain emailDomain � o      ���� 0 emailaddress emailAddress �  � � � l   ��������  ��  ��   �  � � � l   �� � ���   � 2 ,Allow the user to verify their email address    � � � � X A l l o w   t h e   u s e r   t o   v e r i f y   t h e i r   e m a i l   a d d r e s s �  � � � Q    C � ��� � t    : � � � k    9 � �  � � � O   / � � � I  ! .�� � �
�� .sysodlogaskr        TEXT � m   ! " � � � � � � P l e a s e   v e r i f y   t h a t   y o u r   e m a i l   a d d r e s s   i s   c o r r e c t .   E n t e r   a n y   c o r r e c t i o n s . � �� � �
�� 
btns � J   # & � �  ��� � m   # $ � � � � �  O K��   � �� � �
�� 
dflt � m   ' ( � � � � �  O K � �� ���
�� 
dtxt � o   ) *���� 0 emailaddress emailAddress��   � m     � ��                                                                                  sevs  alis    �  Macintosh HD               ����H+  ���System Events.app                                              ��Ր.�        ����  	                CoreServices    ��$      Րg    ���������  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��   �  � � � r   0 3 � � � l  0 1 ����� � 1   0 1��
�� 
rslt��  ��   � o      ���� 0 
the_result   �  ��� � r   4 9 � � � n   4 7 � � � 1   5 7��
�� 
ttxt � o   4 5���� 0 
the_result   � o      ���� 0 emailaddress emailAddress��   � m    ����X � R      ������
�� .ascrerr ****      � ****��  ��  ��   �  � � � l  D D��������  ��  ��   �  � � � l  D D�� � ���   � 9 3Ensure the First Run Outlook screen does not appear    � � � � f E n s u r e   t h e   F i r s t   R u n   O u t l o o k   s c r e e n   d o e s   n o t   a p p e a r �  � � � I  D Y�� � �
�� .sysoexecTEXT���     TEXT � l  D Q ����� � b   D Q � � � b   D M � � � m   D G � � � � � @ / u s r / b i n / d e f a u l t s   w r i t e   " / U s e r s / � o   G L���� 0 	shortname 	shortName � m   M P � � � � � � / L i b r a r y / P r e f e r e n c e s / c o m . m i c r o s o f t . O u t l o o k "   " F i r s t R u n E x p e r i e n c e C o m p l e t e d "   - b o o l   Y E S��  ��   � �� ���
�� 
badm � m   T U�
� boovtrue��   �  � � � I  Z y�~ � �
�~ .sysoexecTEXT���     TEXT � l  Z q ��}�| � b   Z q � � � b   Z m � � � b   Z g � � � b   Z c � � � m   Z ] � � � � �   / u s r / s b i n / c h o w n   � o   ] b�{�{ 0 	shortname 	shortName � m   c f � � �    : s t a f f   " / U s e r s / � o   g l�z�z 0 	shortname 	shortName � m   m p � b / L i b r a r y / P r e f e r e n c e s / c o m . m i c r o s o f t . O u t l o o k . p l i s t "�}  �|   � �y�x
�y 
badm m   t u�w
�w boovtrue�x   �  l  z z�v�u�t�v  �u  �t    l  z z�s�r�q�s  �r  �q   	 l  z z�p
�p  
  Configure the account    � * C o n f i g u r e   t h e   a c c o u n t	  O   z � k   � �  I  � ��o�n�m
�o .miscactvnull��� ��� null�n  �m   �l I  � ��k�j
�k .corecrel****      � null�j   �i
�i 
kocl m   � ��h
�h 
Eact �g�f
�g 
prdt K   � � �e
�e 
pnam o   � ��d�d 0 windowsdomain WindowsDomain �c
�c 
fnam o   � ��b�b 0 fullname FullName �a
�a 
emad o   � ��`�` 0 emailaddress emailAddress �_ !
�_ 
unme  o   � ��^�^ 0 emailaddress emailAddress! �]"#
�] 
host" o   � ��\�\  0 exchangeserver ExchangeServer# �[$�Z
�[ 
pBAD$ m   � ��Y
�Y boovtrue�Z  �f  �l   m   z }%%�                                                                                  OPIM  alis    x  Macintosh HD               ����H+  �E�Microsoft Outlook.app                                          	2��N_0        ����  	                Applications    ��$      �N��    �E�  0Macintosh HD:Applications: Microsoft Outlook.app  ,  M i c r o s o f t   O u t l o o k . a p p    M a c i n t o s h   H D  "Applications/Microsoft Outlook.app  / ��   &'& l  � ��X�W�V�X  �W  �V  ' ()( l  � ��U*+�U  * 3 -Tell the user the account has been configured   + �,, Z T e l l   t h e   u s e r   t h e   a c c o u n t   h a s   b e e n   c o n f i g u r e d) -�T- Q   � �./�S. t   � �010 k   � �22 343 I  � ��R�Q�P
�R .miscactvnull��� ��� null�Q  �P  4 5�O5 O  � �676 I  � ��N89
�N .sysodlogaskr        TEXT8 m   � �:: �;;� Y o u r   e m a i l   a c c o u n t   h a s   b e e n   s u c c e s s f u l l y   c o n f i g u r e d   i n   O u t l o o k .     P l e a s e   a l l o w   5 - 1 0   m i n u t e s   f o r   O u t l o o k   t o   b e g i n   s y n c i n g   y o u r   e m a i l .     P l e a s e   e n t e r   y o u r   p a s s w o r d   o n   a n y   O u t l o o k   d i a l o g s   t h a t   p r o m p t   f o r   y o u r   p a s s w o r d9 �M<=
�M 
btns< J   � �>> ?�L? m   � �@@ �AA  O K�L  = �KB�J
�K 
dfltB m   � �CC �DD  O K�J  7 m   � �EE�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ���System Events.app                                              ��Ր.�        ����  	                CoreServices    ��$      Րg    ���������  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  �O  1 m   � ��I�IX/ R      �H�G�F
�H .ascrerr ****      � ****�G  �F  �S  �T  ��       �EF    2 7 < AGH�E  F 	�D�C�B�A�@�?�>�=�<�D  0 exchangeserver ExchangeServer�C 0 emaildomain emailDomain�B 0 windowsdomain WindowsDomain�A 0 	shortname 	shortName�@ 	0 lname  �? 	0 fname  �> 0 fullname FullName�= $0 createnewaccount createNewAccount
�< .aevtoappnull  �   � ****G �; ��:�9IJ�8�; $0 createnewaccount createNewAccount�:  �9  I �7�6�7 0 emailaddress emailAddress�6 0 
the_result  J ( � ��5 � ��4 ��3 ��2�1�0�/�.�-�, � ��+�* � �%�)�(�'�&�%�$�#�"�!� ���:@C�5X
�4 
btns
�3 
dflt
�2 
dtxt�1 
�0 .sysodlogaskr        TEXT
�/ 
rslt
�. 
ttxt�-  �,  
�+ 
badm
�* .sysoexecTEXT���     TEXT
�) .miscactvnull��� ��� null
�( 
kocl
�' 
Eact
�& 
prdt
�% 
pnam
�$ 
fnam
�# 
emad
�" 
unme
�! 
host
�  
pBAD� � 
� .corecrel****      � null�8 �b  �%b  %�%b  %E�O $�n� ���kv���� UO�E�O��,E�oW X  hOa b  %a %a el Oa b  %a %b  %a %a el Oa  @*j O*a a a a b  a b  a �a �a  b   a !ea "a # $UO &�n*j O� a %�a &kv�a 'a # UoW X  hH �K��LM�
� .aevtoappnull  �   � ****K k     UNN  JOO  SPP  bQQ  qRR  �SS  ���  �  �  L  M  Q� ^ ` m o | ~ ���
� .sysoexecTEXT���     TEXT
� 
badm� $0 createnewaccount createNewAccount� V�j Ec  O�b  %�%j Ec  O�b  %�%j Ec  O�b  %�%j Ec  O��el O*j+ 
ascr  ��ޭ