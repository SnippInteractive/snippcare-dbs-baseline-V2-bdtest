CREATE TABLE [dbo].[ReportParamsSelectOptions] (
    [OptionId]    INT           IDENTITY (1, 1) NOT NULL,
    [Version]     INT           CONSTRAINT [DF_ReportParamsSelectOptions_Version] DEFAULT ((0)) NOT NULL,
    [ParamId]     INT           NOT NULL,
    [OptionValue] INT           NOT NULL,
    [OptionText]  VARCHAR (250) NULL,
    [OptionOrder] INT           NULL,
    CONSTRAINT [PK_ReportParamsSelectOptions] PRIMARY KEY CLUSTERED ([OptionId] ASC),
    CONSTRAINT [FK_ReportParamsSelectOptions_ReportParameter] FOREIGN KEY ([ParamId]) REFERENCES [dbo].[ReportParameter] ([RepParameterId])
);

