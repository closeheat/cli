var Promise,TemplateDownloader,dirmr,fs,ghdownload,gulp,gutil,inject,path,_,__bind=function(t,e){return function(){return t.apply(e,arguments)}};_=require("lodash"),Promise=require("bluebird"),path=require("path"),ghdownload=require("github-download"),dirmr=require("dirmr"),fs=require("fs.extra"),gulp=require("gulp"),inject=require("gulp-inject"),gutil=require("gulp-util"),module.exports=TemplateDownloader=function(){function t(t,e,r){this.dirs=t,this.template=e,this.framework=r,this.injectAssets=__bind(this.injectAssets,this)}return t.prototype.download=function(){return this.cleanTemplateDirs(),this.downloadFromGithub(this.template).then(function(t){return function(){return t.downloadFromGithub(t.framework)}}(this))},t.prototype.downloadFromGithub=function(t){return new Promise(function(e){return function(r,i){return fs.existsSync(e.templateDir(t))?r():ghdownload({user:"closeheat",repo:"template-"+t,ref:"master"},e.templateDir(t)).on("error",i).on("end",r)}}(this))},t.prototype.templateDir=function(t){return path.join(this.dirs.parts,t)},t.prototype.templateDirs=function(){return _.map([this.template,this.framework],function(t){return function(e){return t.templateDir(e)}}(this))},t.prototype.cleanTemplateDirs=function(){return _.each(this.templateDirs(),function(t){return fs.existsSync(t)?fs.rmrfSync(t):void 0})},t.prototype.merge=function(){return this.joinDirs().then(this.injectAssets)},t.prototype.joinDirs=function(){return new Promise(function(t){return function(e,r){return dirmr(t.templateDirs()).join(t.dirs.whole).complete(function(t,i){return t?r(t):i?r(i):e()})}}(this))},t.prototype.injectAssets=function(){return this.silenceGutil(),new Promise(function(t){return function(e,r){var i;return i=gulp.src([path.join(t.dirs.whole,"**/*.min.css"),path.join(t.dirs.whole,"**/*.css"),path.join(t.dirs.whole,"**/*.min.js"),path.join(t.dirs.whole,"js/*.js")],{read:!1}),gulp.src(path.join(t.dirs.whole,"index.html")).pipe(inject(i,{relative:!0,removeTags:!0})).pipe(gulp.dest(t.dirs.whole)).on("error",r).on("end",function(){return t.restoreGutil(),e()})}}(this))},t.prototype.silenceGutil=function(){return this.original_log=gutil.log,gutil.log=gutil.noop},t.prototype.restoreGutil=function(){return gutil.log=this.original_log},t}();
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInRlbXBsYXRlX2Rvd25sb2FkZXIuY29mZmVlIiwidGVtcGxhdGVfZG93bmxvYWRlci5qcyJdLCJuYW1lcyI6WyJQcm9taXNlIiwiVGVtcGxhdGVEb3dubG9hZGVyIiwiZGlybXIiLCJmcyIsImdoZG93bmxvYWQiLCJndWxwIiwiZ3V0aWwiLCJpbmplY3QiLCJwYXRoIiwiXyIsIl9fYmluZCIsImZuIiwibWUiLCJhcHBseSIsImFyZ3VtZW50cyIsInJlcXVpcmUiLCJtb2R1bGUiLCJleHBvcnRzIiwiZGlycyIsInRlbXBsYXRlIiwiZnJhbWV3b3JrIiwidGhpcyIsImluamVjdEFzc2V0cyIsInByb3RvdHlwZSIsImRvd25sb2FkIiwiY2xlYW5UZW1wbGF0ZURpcnMiLCJkb3dubG9hZEZyb21HaXRodWIiLCJ0aGVuIiwiX3RoaXMiLCJyZXNvbHZlIiwicmVqZWN0IiwiZXhpc3RzU3luYyIsInRlbXBsYXRlRGlyIiwidXNlciIsInJlcG8iLCJyZWYiLCJvbiIsImpvaW4iLCJwYXJ0cyIsInRlbXBsYXRlRGlycyIsIm1hcCIsImVhY2giLCJybXJmU3luYyIsIm1lcmdlIiwiam9pbkRpcnMiLCJ3aG9sZSIsImNvbXBsZXRlIiwiZXJyIiwicmVzdWx0Iiwic2lsZW5jZUd1dGlsIiwicGF0aHMiLCJzcmMiLCJyZWFkIiwicGlwZSIsInJlbGF0aXZlIiwicmVtb3ZlVGFncyIsImRlc3QiLCJyZXN0b3JlR3V0aWwiLCJvcmlnaW5hbF9sb2ciLCJsb2ciLCJub29wIl0sIm1hcHBpbmdzIjoiQUFBQSxHQUFBQSxTQUFBQyxtQkFBQUMsTUFBQUMsR0FBQUMsV0FBQUMsS0FBQUMsTUFBQUMsT0FBQUMsS0FBQUMsRUFBQUMsT0FBQSxTQUFBQyxFQUFBQyxHQUFBLE1BQUEsWUFBQSxNQUFBRCxHQUFBRSxNQUFBRCxFQUFBRSxZQUFBTCxHQUFJTSxRQUFRLFVBQVpmLFFBQ1VlLFFBQVEsWUFEbEJQLEtBRU9PLFFBQVEsUUFGZlgsV0FHYVcsUUFBUSxtQkFIckJiLE1BSVFhLFFB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NUIsTUFBQ3FDLGFBQWVwRCxNQUFNcUQsSUFDdEJyRCxNQUFNcUQsSUFBTXJELE1BQU1zRCxNQWhFcEIzRCxFQUFBc0IsVUFrRUFrQyxhQUFjLFdDd0NaLE1EdkNBbkQsT0FBTXFELElBQU10QyxLQUFDcUMsY0MwQ1J6RCIsImZpbGUiOiJ0ZW1wbGF0ZV9kb3dubG9hZGVyLmpzIiwic291cmNlc0NvbnRlbnQiOlsiXyA9IHJlcXVpcmUgJ2xvZGFzaCdcblByb21pc2UgPSByZXF1aXJlICdibHVlYmlyZCdcbnBhdGggPSByZXF1aXJlICdwYXRoJ1xuZ2hkb3dubG9hZCA9IHJlcXVpcmUoJ2dpdGh1Yi1kb3dubG9hZCcpXG5kaXJtciA9IHJlcXVpcmUoJ2Rpcm1yJylcbmZzID0gcmVxdWlyZSAnZnMuZXh0cmEnXG5ndWxwID0gcmVxdWlyZSAnZ3VscCdcbmluamVjdCA9IHJlcXVpcmUgJ2d1bHAtaW5qZWN0J1xuZ3V0aWwgPSByZXF1aXJlKCdndWxwLXV0aWwnKVxuXG5tb2R1bGUuZXhwb3J0cyA9XG5jbGFzcyBUZW1wbGF0ZURvd25sb2FkZXJcbiAgY29uc3RydWN0b3I6IChAZGlycywgQHRlbXBsYXRlLCBAZnJhbWV3b3JrKSAtPlxuXG4gIGRvd25sb2FkOiAtPlxuICAgIEBjbGVhblRlbXBsYXRlRGlycygpXG5cbiAgICBAZG93bmxvYWRGcm9tR2l0aHViKEB0ZW1wbGF0ZSkudGhlbiA9PlxuICAgICAgQGRvd25sb2FkRnJvbUdpdGh1YihAZnJhbWV3b3JrKVxuXG4gIGRvd25sb2FkRnJvbUdpdGh1YjogKHRlbXBsYXRlKSAtPlxuICAgIG5ldyBQcm9taXNlIChyZXNvbHZlLCByZWplY3QpID0+XG4gICAgICByZXR1cm4gcmVzb2x2ZSgpIGlmIGZzLmV4aXN0c1N5bmMgQHRlbXBsYXRlRGlyKHRlbXBsYXRlKVxuXG4gICAgICBnaGRvd25sb2FkKFxuICAgICAgICB1c2VyOiAnY2xvc2VoZWF0JyxcbiAgICAgICAgcmVwbzogXCJ0ZW1wbGF0ZS0je3RlbXBsYXRlfVwiLFxuICAgICAgICByZWY6ICdtYXN0ZXInLFxuICAgICAgICBAdGVtcGxhdGVEaXIodGVtcGxhdGUpXG4gICAgICApXG4gICAgICAub24oJ2Vycm9yJywgcmVqZWN0KVxuICAgICAgLm9uKCdlbmQnLCByZXNvbHZlKVxuXG4gIHRlbXBsYXRlRGlyOiAodGVtcGxhdGUpIC0+XG4gICAgcGF0aC5qb2luKEBkaXJzLnBhcnRzLCB0ZW1wbGF0ZSlcblxuICB0ZW1wbGF0ZURpcnM6IC0+XG4gICAgXy5tYXAgW0B0ZW1wbGF0ZSwgQGZyYW1ld29ya10sICh0ZW1wbGF0ZSkgPT5cbiAgICAgIEB0ZW1wbGF0ZURpcih0ZW1wbGF0ZSlcblxuICBjbGVhblRlbXBsYXRlRGlyczogLT5cbiAgICBfLmVhY2ggQHRlbXBsYXRlRGlycygpLCAodGVtcGxhdGUpIC0+XG4gICAgICBmcy5ybXJmU3luYyh0ZW1wbGF0ZSkgaWYgZnMuZXhpc3RzU3luYyB0ZW1wbGF0ZVxuXG4gIG1lcmdlOiAtPlxuICAgIEBqb2luRGlycygpLnRoZW4oQGluamVjdEFzc2V0cylcblxuICBqb2luRGlyczogLT5cbiAgICBuZXcgUHJvbWlzZSAocmVzb2x2ZSwgcmVqZWN0KSA9PlxuICAgICAgZGlybXIoQHRlbXBsYXRlRGlycygpKS5qb2luKEBkaXJzLndob2xlKS5jb21wbGV0ZSAoZXJyLCByZXN1bHQpID0+XG4gICAgICAgIHJldHVybiByZWplY3QoZXJyKSBpZiBlcnJcbiAgICAgICAgcmV0dXJuIHJlamVjdChyZXN1bHQpIGlmIHJlc3VsdFxuXG4gICAgICAgIHJlc29sdmUoKVxuXG4gIGluamVjdEFzc2V0czogPT5cbiAgICBAc2lsZW5jZUd1dGlsKClcblxuICAgIG5ldyBQcm9taXNlIChyZXNvbHZlLCByZWplY3QpID0+XG4gICAgICBwYXRocyA9IGd1bHAuc3JjKFtcbiAgICAgICAgcGF0aC5qb2luKEBkaXJzLndob2xlLCAnKiovKi5taW4uY3NzJylcbiAgICAgICAgcGF0aC5qb2luKEBkaXJzLndob2xlLCAnKiovKi5jc3MnKVxuICAgICAgICBwYXRoLmpvaW4oQGRpcnMud2hvbGUsICcqKi8qLm1pbi5qcycpXG4gICAgICAgIHBhdGguam9pbihAZGlycy53aG9sZSwgJ2pzLyouanMnKVxuICAgICAgXVxuICAgICAgLCByZWFkOiBmYWxzZSlcblxuICAgICAgZ3VscFxuICAgICAgICAuc3JjKHBhdGguam9pbihAZGlycy53aG9sZSwgJ2luZGV4Lmh0bWwnKSlcbiAgICAgICAgLnBpcGUoaW5qZWN0KHBhdGhzLCByZWxhdGl2ZTogdHJ1ZSwgcmVtb3ZlVGFnczogdHJ1ZSkpXG4gICAgICAgIC5waXBlKGd1bHAuZGVzdChAZGlycy53aG9sZSkpXG4gICAgICAgIC5vbignZXJyb3InLCByZWplY3QpXG4gICAgICAgIC5vbignZW5kJywgKD0+IEByZXN0b3JlR3V0aWwoKTsgcmVzb2x2ZSgpKSlcblxuICBzaWxlbmNlR3V0aWw6IC0+XG4gICAgQG9yaWdpbmFsX2xvZyA9IGd1dGlsLmxvZ1xuICAgIGd1dGlsLmxvZyA9IGd1dGlsLm5vb3BcblxuICByZXN0b3JlR3V0aWw6IC0+XG4gICAgZ3V0aWwubG9nID0gQG9yaWdpbmFsX2xvZ1xuIixudWxsXSwic291cmNlUm9vdCI6Ii9zb3VyY2UvIn0=