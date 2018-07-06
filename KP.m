BeginPackage["KP`", {"Notation`"}]

PrettyPrint::usage = "Prints the given variable and its Value in a new cell"
SetPrettyPrint::usage = "Prints the given variable and its then assigned value in a new cell"

SetKLabel::usage = "s"
GetKLabel::usage = "g"
KSave::usage = "todo"


Begin["`Private`"]


(* Add compatibility for datasets to directly work with linearfits by automatically converting it to list of lists *)

Dataset;
Unprotect[Dataset];
Dataset /: LinearModelFit[ds_Dataset?Dataset`ValidDatasetQ, rest___] :=
  LinearModelFit[Normal@ds, rest]
Protect[Dataset];





(* Define two new Operator, that "log" the assignemt of the variables in a nicer way. *)
(* [ESC]=p[ESC] acts like =, but also prints an output cell with   "[LHS] = [RHS]"    *)
(* [ESC]=?[ESC] is used after an variable, to print like the above,  but without set  *)

PrettyPrintColor = RGBColor[0.0, 0.0, 0.5] (*Used in PrettyPrint, SetPrettyPrint*)

Clear[PrettyPrint];
PrettyPrint[x_Symbol] := 
	CellPrint[
		Style[TextCell[
			Row[{
				ExpressionCell[HoldForm[x]],
				" = ",
				ExpressionCell[x]}]
			], 
   			PrettyPrintColor
   		]
   	];
SetAttributes[PrettyPrint, HoldAll];
Notation[
	ParsedBoxWrapper[
		RowBox[{
			"x_",
			" ",
			TagBox[
				SuperscriptBox["=", "?"],
				PrettyPrintOperator,
				Editable -> False, Selectable -> False
       		]
       	}]
	]
	\[DoubleLongRightArrow] 
    ParsedBoxWrapper[RowBox[{"PrettyPrint", "[", "x_", "]"}]]
];
AddInputAlias[
	"=?" -> ParsedBoxWrapper[
		TagBox[SuperscriptBox["=", "?"],
		PrettyPrintOperator,
		Editable -> False, Selectable -> False]
	]
];


Clear[SetPrettyPrint];
SetPrettyPrint[x_, y_] := 
	Module[{},
		CellPrint[
			Style[
				TextCell[Row[{
					ExpressionCell[HoldForm[x]],
					" = ", 
       	 			ExpressionCell[y]
       	 		}]],
      	 		PrettyPrintColor
			]
   		];
   		x = y;
	];  	
SetAttributes[SetPrettyPrint, HoldAll];
Notation[
	ParsedBoxWrapper[RowBox[{"x_", " ", TagBox[OverscriptBox["=", Cell["PRINT"]], SetPrettyPrintOperator, Editable -> False, Selectable -> False], " ", "y_"}]]
	\[DoubleLongLeftRightArrow] 
	ParsedBoxWrapper[
		RowBox[{"SetPrettyPrint", "[", RowBox[{"x_", ",", " ", "y_"}], "]"}]
	]
];
AddInputAlias[
	"=p" -> ParsedBoxWrapper[
		TagBox[OverscriptBox["=", Cell["PRINT"]],
		SetPrettyPrintOperator,
		Editable -> False, Selectable -> False]
	]
];


Clear[SetKLabel];
SetKLabel[lx_String, ly_String] := Block[{}, KP`klabel = {lx, ly}];
Clear[GetKLabel];
GetKLabel[] := KP`klabel;


Begin["System`PlotThemeDump`"];
	Themes`ThemeRules;(*preload Theme system*)(*Define the base theme*)
	resolvePlotTheme["Gpr", def:_String] := 
		Themes`SetWeight[Join[
			{Axes -> True},
			{Frame -> True},
			{ImageSizeRaw -> {360, 360}, AxesLabel},
			{DisplayFunction -> (Labeled[#,GetKLabel[], {Bottom, Left}, RotateLabel->True, ImageMargins -> {10}]&)}
		],
		Themes`$DesignWeight
	];
End[];


Clear[KSave]
KSave[g_, filename_String] :=
Block[
{
	backupdirectory,
	backupfilepath,
	localdirectory,
	fileending = ".png"
},
	localdirectory = NotebookDirectory[];
	backupdirectory = StringJoin[{localdirectory, "backup\\"}];
	If[ \[Not] DirectoryQ[backupdirectory], CreateDirectory[backupdirectory]];
 		
	backupfilepath = StringJoin[{backupdirectory, filename, "-",
   		DateString[{"Year", "-", "Month", "-",  "Day", "-", "Hour", "-", 
   		"Minute", "-", "Second"}],
   		fileending}
   	];
		
	Print[backupfilepath];
	Export[backupfilepath, g];
	Export[StringJoin [{localdirectory, filename, fileending}], g];
	"Saved!"
]



End[];
EndPackage[];