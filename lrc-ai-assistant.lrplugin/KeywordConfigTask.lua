
LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("Edit keyword categories", function(context)
        KeywordConfigProvider.showKeywordCategoryDialog()
    end)
end)