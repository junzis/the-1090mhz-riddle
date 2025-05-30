\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{r1090}

\newif\if@print
\DeclareOption{print}{\@printtrue}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax

\LoadClass[10pt]{book}

\usepackage{ifthen}
\usepackage{geometry}

%% Set the paper size
\if@print
  %% In print mode we add a 3 mm bleed on the all sides of the page.
  \geometry{
    papersize = {162mm,240mm},
    layoutsize = {156mm,234mm},   % Royal
    layoutoffset = {3mm,3mm},
    inner = 17mm,
    outer = 14mm,
    top = 19mm,
    bottom = 16mm,
    footskip = 6mm,
  }
\else
  \geometry{
    papersize={156mm,234mm},
    inner = 14mm,
    outer = 14mm,
    top = 19mm,
    bottom = 16mm,
    footskip = 6mm,
  }
\fi


\usepackage[utf8]{inputenc}
\usepackage[LGR,T1]{fontenc}


\usepackage[headings]{ncchdr}
\usepackage{graphicx}
\usepackage{charter}
\usepackage{booktabs}
\usepackage{multirow}
\usepackage{amssymb,amsmath,mathtools}
\usepackage{ifxetex,ifluatex}
\usepackage{tikz}
\usetikzlibrary{positioning,shapes,arrows,fadings,patterns}
\usepackage{emptypage}
\usepackage{setspace}

\usepackage{threeparttable}

%\usepackage{makeidx}
%\makeindex

% customized color
\definecolor{gray97}{gray}{0.97}
\definecolor{gray95}{gray}{0.95}
\definecolor{gray90}{gray}{0.90}
\definecolor{gray70}{gray}{0.7}
\definecolor{gray50}{gray}{0.5}
\definecolor{gray40}{gray}{0.4}
\definecolor{gray20}{gray}{0.2}


% beak in table cell
\usepackage{makecell}
\renewcommand{\cellalign}{l}

\usepackage{subcaption}

\usepackage{arydshln}

\setcounter{secnumdepth}{2}

% footnote style
\usepackage[hang,flushmargin]{footmisc}
\setlength{\footnotemargin}{2mm}


\usepackage[unicode=true]{hyperref}
\PassOptionsToPackage{hyphens}{url}
% \urlstyle{same}  % don't use monospace font for urls

\usepackage{parskip}
\setlength{\emergencystretch}{3em}  % prevent overfull lines
\setlength{\parskip}{0.6em}
\renewcommand{\baselinestretch}{1.05}


%% note box
\usepackage[most]{tcolorbox}
\newtcolorbox{notebox}[2][]{
  boxed title style={boxrule=0pt, sharp corners},
  colback=gray90,
  attach boxed title to top left={xshift=2mm,yshift=-3mm},
  enhanced,
  sharp corners,
  top=4mm,
  boxrule=0.5pt,
  title=#2,#1,
  fontupper=\small,
  enlarge top by=3mm
}


%  verbatim and texttt style
\usepackage{fancyvrb,newverbs,xcolor}
\usepackage{letltxmacro}

\LetLtxMacro{\oldverbatim}{\verbatim}

\renewenvironment{verbatim}
 {\SaveVerbatim{cverb}}
 {\endSaveVerbatim
  \fboxsep=1em
  \center
  \colorbox{gray90}{\footnotesize\BUseVerbatim{cverb}}%
  \endcenter}

\LetLtxMacro{\oldtexttt}{\texttt}
\renewcommand{\texttt}[1]{\colorbox{gray90}{\oldtexttt{#1}}}
% [end verbatim and texttt style]


% setup table styles
\usepackage{floatrow}
\floatsetup[table]{font=small,capposition=top}
\renewcommand{\arraystretch}{1.1}
\usepackage{tabularx}

% chapter title style
\usepackage{titlesec}
\titleformat{\chapter}[hang]
  {\huge\bfseries\filright}
  {\thechapter\hspace{5pt}\textcolor{gray70}{|}\hspace{5pt}}
  {0pt}
  {\LARGE\bfseries}

\titlespacing*{\chapter}{0pt}{-20pt}{20pt}

% reference styles
% \usepackage[style=footnote-dw,giveninits=true,maxbibnames=10]{biblatex}
\usepackage[giveninits=true,maxbibnames=10]{biblatex}
\addbibresource{references.bib}
\AtNextBibliography{\small}
\DeclareNameAlias{author}{last-first}

%% Dedication, vertically centered on a separate page, flushed to the right
\newcommand\dedication[1]{%
    \thispagestyle{empty}%
    \vspace*{\fill}%
    \begin{flushright}%
        #1%
    \end{flushright}%
    \vspace*{\fill}%
    %\cleardoublepage
}

%% Redefine the title command to accept an optional subtitle.
\renewcommand*\title[2][]{%
    \def\@subtitle{#1}%
    \def\@title{#2}%
    %% Add the title to the PDF meta data.
    \hypersetup{pdftitle=#2}%
}

%% Redefine the author command to accept a first and last name, and to add the
%% full name to the PDF meta data.
\renewcommand*\author[2]{%
    \def\@firstname{#1}%
    \def\@lastname{#2}%
    \hypersetup{pdfauthor=#1\ #2}%
}


\def\titlefont{\fontencoding{OT1}\fontfamily{epigrafica}\selectfont}
\def\titleshape{\scshape} %% The style for titles is small caps.
\def\titleshape{}
\def\titlestyle{\titlefont\titleshape\bfseries}
\def\headerstyle{\titlefont\titleshape\bfseries}


\usepackage{enumitem}
\setitemize{noitemsep,topsep=0pt,parsep=2pt,partopsep=0pt}

%% remove page number on chapter and part page
% \makeatletter
% \renewcommand\ps@plain{\let\@mkboth\@gobbletwo
%      \let\@oddhead\@empty
%      \def\@oddfoot{\reset@font\hfil}
%      \let\@evenhead\@empty\let\@evenfoot\@oddfoot}
% \makeatother

\if@print
  \usepackage{background}
  \usetikzlibrary{calc}

  \backgroundsetup{
    scale=1,
    opacity=1,
    angle=0,
    color=gray,
    contents={
      \begin{tikzpicture}[remember picture, overlay]
        \draw [line width=0.2mm]
            ($ (current page.south west) + (3mm, 3mm) $)
            rectangle
            ($ (current page.north east) + (-3mm, -3mm)$);
      \end{tikzpicture}
    }
  }
\fi
